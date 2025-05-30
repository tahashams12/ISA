from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict
import pandas as pd
import numpy as np
import pickle
import uuid
from datetime import datetime
import joblib
import json

app = FastAPI(title="Sentiment Analysis API", version="1.0.0")

# Enable CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Data Models
class Review(BaseModel):
    id: str
    categoryName: str
    latitude: float
    longitude: float
    title: str
    stars: float
    averageRating: float
    cleanedText: str
    sentiment: str

class UserReview(BaseModel):
    placeTitle: str
    reviewText: str
    

class PredictionResponse(BaseModel):
    sentiment: str
    confidence: float

class AltSentimentRequest(BaseModel):
    text: str


# Global variables to store data and model
reviews_data = []
model = None
vectorizer = None

# Load the trained model and vectorizer
def load_model():
    global model, vectorizer
    model = joblib.load("model.pkl")
    vectorizer = joblib.load("vectorizer.pkl")

# Load data from CSV
def load_data_from_csv():
    global reviews_data
    
    try:
        # Path to the CSV file
        csv_path = 'data/reviews.csv'
        
        # Read the CSV file
        df = pd.read_csv(csv_path)
        
        # Convert DataFrame to list of dictionaries
        reviews_list = df.to_dict('records')
        
        # Ensure all data types are correct
        formatted_reviews = []
        for review in reviews_list:
            formatted_review = {
                "id": str(review.get('id', uuid.uuid4())),
                "categoryName": str(review.get('categoryName', '')),
                "latitude": float(review.get('latitude', 0.0)),
                "longitude": float(review.get('longitude', 0.0)),
                "title": str(review.get('title', '')),
                "stars": float(review.get('stars', 0.0)),
                "averageRating": float(review.get('averageRating', 0.0)),
                "cleanedText": str(review.get('cleanedText', '')),
                "sentiment": str(review.get('sentiment', 'Neutral'))
            }
            formatted_reviews.append(formatted_review)
        
        reviews_data = formatted_reviews
        print(f"Successfully loaded {len(reviews_data)} reviews from CSV")
        
    except FileNotFoundError:
        print("CSV file not found. Creating a sample dataset.")
        # Create a minimal sample dataset as fallback
        reviews_data = [
            {
                "id": str(uuid.uuid4()),
                "categoryName": "Hospitals",
                "latitude": 33.7293,
                "longitude": 73.0931,
                "title": "PIMS Hospital",
                "stars": 4.2,
                "averageRating": 4.0,
                "cleanedText": "Excellent medical care and professional staff. Highly recommended for serious medical conditions.",
                "sentiment": "Positive"
            },
            {
                "id": str(uuid.uuid4()),
                "categoryName": "Malls",
                "latitude": 33.7233, 
                "longitude": 73.0570,
                "title": "Centaurus Mall",
                "stars": 4.6,
                "averageRating": 4.5,
                "cleanedText": "Great shopping experience with many stores and good food court options.",
                "sentiment": "Positive"
            }
        ]
    except Exception as e:
        print(f"Error loading CSV data: {e}")
        reviews_data = []

# Save reviews data to CSV
def save_data_to_csv():
    global reviews_data
    
    try:
        # Path to the CSV file
        csv_path = 'data/reviews.csv'
        
        # Convert reviews data to DataFrame
        df = pd.DataFrame(reviews_data)
        
        # Save DataFrame to CSV
        df.to_csv(csv_path, index=False)
        
        print(f"Successfully saved {len(reviews_data)} reviews to CSV")
        
    except Exception as e:
        print(f"Error saving data to CSV: {e}")

# Predict sentiment for new review
def predict_sentiment(text: str) -> tuple:
    global model, vectorizer
    
    if model is None or vectorizer is None:
        return "Neutral", 0.5
    
    try:
        # Vectorize the text
        text_vector = vectorizer.transform([text])
        
        # Predict sentiment
        prediction = model.predict(text_vector)[0]
        
        # Get prediction probabilities for confidence
        probabilities = model.predict_proba(text_vector)[0]
        confidence = max(probabilities)
        
        return prediction, confidence
    except Exception as e:
        print(f"Error in prediction: {e}")
        return "Neutral", 0.5

# API Endpoints
@app.on_event("startup")
async def startup_event():
    load_model()
    load_data_from_csv()

@app.get("/")
async def root():
    return {"message": "Sentiment Analysis API is running"}

@app.get("/reviews", response_model=List[Review])
async def get_reviews():
    """Get all reviews"""
    return reviews_data

@app.get("/sentiment-distribution")
async def get_sentiment_distribution():
    """Get sentiment distribution counts"""
    sentiment_counts = {"Positive": 0, "Neutral": 0, "Negative": 0}
    
    for review in reviews_data:
        sentiment = review["sentiment"]
        if sentiment in sentiment_counts:
            sentiment_counts[sentiment] += 1
    
    return sentiment_counts

@app.post("/submit-review")
async def submit_review(user_review: UserReview):
    """Submit a new review and predict its sentiment"""
    try:
        # Predict sentiment for the new review
        predicted_sentiment, confidence = predict_sentiment(user_review.reviewText)
        
        # Find the place to get location and category info
        place_info = None
        for review in reviews_data:
            if review["title"] == user_review.placeTitle:
                place_info = review
                break
        
        if not place_info:
            raise HTTPException(status_code=404, detail="Place not found")
        
        # Create new review entry
        new_review = {
            "id": str(uuid.uuid4()),
            "categoryName": place_info["categoryName"],
            "latitude": place_info["latitude"],
            "longitude": place_info["longitude"],
            "title": user_review.placeTitle,
            "stars": 3.0,  # Default rating, can be adjusted
            "averageRating": place_info["averageRating"],  # Keep existing average
            "cleanedText": user_review.reviewText,
            "sentiment": predicted_sentiment
        }
        
        # Add to reviews data
        reviews_data.append(new_review)
        
        # Save updated reviews data to CSV
        save_data_to_csv()
        
        return {
            "message": "Review submitted successfully",
            "predicted_sentiment": predicted_sentiment,
            "confidence": confidence,
            "review_id": new_review["id"]
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing review: {str(e)}")

@app.post("/predict-sentiment", response_model=PredictionResponse)
async def predict_review_sentiment(text: str):
    """Predict sentiment for a given text"""
    try:
        sentiment, confidence = predict_sentiment(text)
        return PredictionResponse(sentiment=sentiment, confidence=confidence)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error predicting sentiment: {str(e)}")

@app.get("/categories")
async def get_categories():
    """Get all unique categories"""
    categories = list(set(review["categoryName"] for review in reviews_data))
    return {"categories": categories}

@app.get("/places")
async def get_places():
    """Get all unique place titles"""
    places = list(set(review["title"] for review in reviews_data))
    return {"places": places}

@app.get("/reviews/category/{category}")
async def get_reviews_by_category(category: str):
    """Get reviews filtered by category"""
    filtered_reviews = [review for review in reviews_data if review["categoryName"] == category]
    return filtered_reviews


@app.post("/predict-sentiment-alt", response_model=PredictionResponse)
async def predict_sentiment_alternative(request: AltSentimentRequest):
    try:
        # You can modify this function if needed to use a different logic or model
        sentiment, confidence = predict_sentiment(request.text)
        return PredictionResponse(sentiment=sentiment, confidence=confidence)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error in alt sentiment prediction: {str(e)}")


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "total_reviews": len(reviews_data),
        "model_loaded": model is not None and vectorizer is not None
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)