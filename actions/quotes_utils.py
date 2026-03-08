import json
import random
import re
import os
from collections import Counter, defaultdict

class QuoteManager:
    """Advanced quote management system for Render"""
    
    def __init__(self, quotes_path="actions/quotes.json"):
        self.quotes = []
        self.quotes_by_category = defaultdict(list)
        self.quotes_by_author = defaultdict(list)
        self.quotes_by_tag = defaultdict(list)
        self.author_popularity = Counter()
        self.category_popularity = Counter()
        self.session_history = []
        
        self.load_quotes(quotes_path)
        
    def load_quotes(self, path):
        """Load and index quotes with Render path handling"""
        quotes = []
        
        # Try multiple paths for Render
        paths_to_try = [
            path,
            "actions/quotes.json",
            "/opt/render/project/src/actions/quotes.json",
            os.path.join(os.path.dirname(__file__), "quotes.json")
        ]
        
        for try_path in paths_to_try:
            try:
                with open(try_path, 'r', encoding='utf-8') as f:
                    quotes = json.load(f)
                print(f"✅ Loaded quotes from: {try_path}")
                break
            except:
                continue
        
        if not quotes:
            print("⚠️ Using fallback quotes")
            quotes = self.get_fallback_quotes()
        
        # Deduplicate
        seen = set()
        for q in quotes:
            quote_text = q.get("Quote", "").strip()
            if not quote_text or len(quote_text) < 5 or quote_text.lower() in seen:
                continue
            
            seen.add(quote_text.lower())
            
            # Clean and enrich
            cleaned = {
                "Quote": quote_text,
                "Author": q.get("Author", "Unknown"),
                "Category": q.get("Category", "uncategorized").lower(),
                "Tags": [t.lower() for t in q.get("Tags", [])],
                "Length": len(quote_text.split())
            }
            
            self.quotes.append(cleaned)
            
            # Index
            self.quotes_by_category[cleaned["Category"]].append(cleaned)
            self.quotes_by_author[cleaned["Author"]].append(cleaned)
            for tag in cleaned["Tags"]:
                self.quotes_by_tag[tag].append(cleaned)
        
        print(f"✅ Loaded {len(self.quotes)} unique quotes")
        
    def get_fallback_quotes(self):
        """Fallback quotes if file not found"""
        return [
            {"Quote": "The only way to do great work is to love what you do.", 
             "Author": "Steve Jobs", "Category": "motivation", "Tags": ["work", "passion"]},
            {"Quote": "Life is what happens when you're busy making other plans.", 
             "Author": "John Lennon", "Category": "life", "Tags": ["wisdom", "present"]}
        ]
    
    def get_quote(self, category=None, author=None, tags=None, exclude_quotes=None):
        """Get quote with advanced filtering"""
        candidates = self.quotes.copy()
        
        # Apply filters
        if category and category in self.quotes_by_category:
            candidates = self.quotes_by_category[category]
        
        if author:
            author = author.lower()
            candidates = [q for q in candidates 
                         if q["Author"].lower() == author]
        
        if tags:
            tags = [t.lower() for t in tags]
            candidates = [q for q in candidates 
                         if any(t in q["Tags"] for t in tags)]
        
        # Exclude recent quotes
        if exclude_quotes and candidates:
            candidates = [q for q in candidates 
                         if q["Quote"] not in exclude_quotes[-10:]]
        
        if not candidates:
            candidates = self.quotes
        
        quote = random.choice(candidates) if candidates else random.choice(self.quotes)
        self.author_popularity[quote["Author"]] += 1
        self.category_popularity[quote["Category"]] += 1
        self.session_history.append(quote["Quote"])
        
        return quote

# Global instance
quote_manager = QuoteManager()

def get_sentiment(text):
    """Simple sentiment analysis"""
    positive_words = {'happy', 'great', 'good', 'awesome', 'love', 'joy', 'excited'}
    negative_words = {'sad', 'bad', 'upset', 'angry', 'depressed', 'lonely', 'stressed'}
    
    words = set(re.findall(r'\w+', text.lower()))
    pos_count = len(words.intersection(positive_words))
    neg_count = len(words.intersection(negative_words))
    
    if pos_count > neg_count:
        return "positive", pos_count - neg_count
    elif neg_count > pos_count:
        return "negative", neg_count - pos_count
    return "neutral", 0