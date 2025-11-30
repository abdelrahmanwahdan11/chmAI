import uvicorn
import os
import sys

# Add the current directory to python path to ensure imports work
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

if __name__ == "__main__":
    print("Starting ChemAI Industrial OS Backend...")
    print("Server will be available at http://127.0.0.1:8000")
    print("Press Ctrl+C to stop.")
    
    # Run the FastAPI application
    # 'main:app' refers to the 'app' object in 'main.py'
    # reload=True allows the server to restart when code changes
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
