import os
import re
import requests
import sys

# Configuration
AUTHOR_ID = "57205709572"
API_KEY = os.environ.get("SCOPUS_API_KEY")
INDEX_FILE = "index.html"

if not API_KEY:
    print("Error: SCOPUS_API_KEY environment variable is not set.", file=sys.stderr)
    sys.exit(1)

# Fetch from Scopus API
url = f"https://api.elsevier.com/content/author/author_id/{AUTHOR_ID}"
headers = {
    "Accept": "application/json",
    "X-ELS-APIKey": API_KEY
}

try:
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    data = response.json()
    
    # Parse metrics
    coredata = data.get("author-retrieval-response", [{}])[0].get("coredata", {})
    
    h_index = coredata.get("h-index", "")
    citations = coredata.get("citation-count", "")
    documents = coredata.get("document-count", "")
    
    if not h_index or not citations:
        print("Failed to extract metrics from API response.", file=sys.stderr)
        sys.exit(1)
        
    print(f"Fetched Scopus Metrics: h-index={h_index}, citations={citations}, docs={documents}")
    
    # Read index.html
    with open(INDEX_FILE, 'r', encoding='utf-8') as f:
        html = f.read()
        
    # Replace metrics using regex
    # Scopus H-index
    html = re.sub(r'id="scopus-hindex"[^>]*>.*?</div>', f'id="scopus-hindex">{h_index}</div>', html)
    html = re.sub(r'id="hero-scopus-hindex"[^>]*>.*?</span>', f'id="hero-scopus-hindex">{h_index}</span>', html)
    
    # Scopus Citations
    html = re.sub(r'id="scopus-citations"[^>]*>.*?</div>', f'id="scopus-citations">{citations}</div>', html)
    
    # Write back
    with open(INDEX_FILE, 'w', encoding='utf-8') as f:
        f.write(html)
        
    print("Successfully updated index.html with new Scopus metrics.")
    
except Exception as e:
    print(f"Error occurred: {e}", file=sys.stderr)
    sys.exit(1)
