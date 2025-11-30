"""
Test script for Chemistry Structure API Endpoints
Tests the 2D and 3D structure generation endpoints
"""

import requests
import json

# Base URL
BASE_URL = "http://localhost:8000/api/chemistry"

def test_2d_structure():
    """Test 2D structure generation endpoint"""
    print("\n=== Testing 2D Structure Generation ===")
    
    test_molecules = [
        ("Water", "O"),
        ("Ethanol", "CCO"),
        ("Benzene", "c1ccccc1"),
        ("Aspirin", "CC(=O)Oc1ccccc1C(=O)O"),
    ]
    
    for name, smiles in test_molecules:
        print(f"\nTesting {name} (SMILES: {smiles})")
        try:
            response = requests.post(
                f"{BASE_URL}/structure/2d",
                json={"smiles": smiles},
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"  ✓ Success!")
                print(f"  - Formula: {data.get('formula')}")
                print(f"  - Atoms: {len(data.get('atoms', []))}")
                print(f"  - Bonds: {len(data.get('bonds', []))}")
            else:
                print(f"  ✗ Error: {response.status_code}")
                print(f"  - {response.text}")
                
        except requests.exceptions.ConnectionError:
            print(f"  ✗ Connection Error: Backend is not running")
            print(f"  - Start the backend with: cd backend && uvicorn main:app --reload")
            return False
        except Exception as e:
            print(f"  ✗ Exception: {e}")
            
    return True


def test_3d_structure():
    """Test 3D structure generation endpoint"""
    print("\n\n=== Testing 3D Structure Generation ===")
    
    test_molecules = [
        ("Water", "O"),
        ("Methane", "C"),
        ("Ethanol", "CCO"),
    ]
    
    for name, smiles in test_molecules:
        print(f"\nTesting {name} (SMILES: {smiles})")
        try:
            response = requests.post(
                f"{BASE_URL}/structure/3d",
                json={"smiles": smiles},
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"  ✓ Success!")
                print(f"  - Formula: {data.get('formula')}")
                print(f"  - Atoms: {len(data.get('atoms', []))}")
                print(f"  - Bonds: {len(data.get('bonds', []))}")
                print(f"  - Is 3D: {data.get('is_3d', False)}")
                
                # Check if atoms have 3D coordinates
                if data.get('atoms'):
                    first_atom = data['atoms'][0]
                    has_3d = 'z' in first_atom
                    print(f"  - Has Z coordinates: {has_3d}")
            else:
                print(f"  ✗ Error: {response.status_code}")
                print(f"  - {response.text}")
                
        except requests.exceptions.ConnectionError:
            print(f"  ✗ Connection Error: Backend is not running")
            return False
        except Exception as e:
            print(f"  ✗ Exception: {e}")
            
    return True


def test_descriptors():
    """Test molecular descriptors endpoint"""
    print("\n\n=== Testing Molecular Descriptors ===")
    
    smiles = "CCO"  # Ethanol
    print(f"\nTesting Ethanol (SMILES: {smiles})")
    
    try:
        response = requests.post(
            f"{BASE_URL}/structure/descriptors",
            json={"smiles": smiles},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"  ✓ Success!")
            print(f"\nBasic Descriptors:")
            if 'basic' in data:
                for key, value in data['basic'].items():
                    print(f"  - {key}: {value}")
            
            print(f"\nPhysicochemical Properties:")
            if 'physicochemical' in data:
                for key, value in data['physicochemical'].items():
                    print(f"  - {key}: {value:.2f}" if isinstance(value, float) else f"  - {key}: {value}")
        else:
            print(f"  ✗ Error: {response.status_code}")
            print(f"  - {response.text}")
            
    except requests.exceptions.ConnectionError:
        print(f"  ✗ Connection Error: Backend is not running")
        return False
    except Exception as e:
        print(f"  ✗ Exception: {e}")
        
    return True


if __name__ == "__main__":
    print("=" * 60)
    print("ChemAI Structure API Test Suite")
    print("=" * 60)
    
    # Run tests
    success = True
    success = test_2d_structure() and success
    if success:
        success = test_3d_structure() and success
    if success:
        success = test_descriptors() and success
    
    # Summary
    print("\n" + "=" * 60)
    if success:
        print("✓ All tests completed successfully!")
    else:
        print("✗ Some tests failed. Check the output above.")
    print("=" * 60)
