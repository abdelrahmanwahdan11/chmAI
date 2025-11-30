import sys
import os
import unittest
from unittest.mock import MagicMock, patch

# Add backend directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from routers import inventory_router
from chemistry_engine.periodic_table import periodic_table_service
from models import Material

class TestFilters(unittest.TestCase):
    
    def test_inventory_search_filter(self):
        """Test the inventory search logic (mocking DB)"""
        print("\nTesting Inventory Search Filter...")
        
        # Mock DB Session
        mock_db = MagicMock()
        mock_query = mock_db.query.return_value
        mock_filter = mock_query.filter.return_value
        
        # Test empty query (should return all/limit)
        inventory_router.search_inventory(q="", db=mock_db)
        mock_query.limit.assert_called()
        print("✓ Empty query handled correctly")
        
        # Test search query
        inventory_router.search_inventory(q="Sodium", db=mock_db)
        # Verify filter was called
        # Note: We can't easily assert the exact filter expression object, 
        # but we can verify filter() was called
        mock_query.filter.assert_called()
        print("✓ Search query triggers filter")

    def test_periodic_table_filter(self):
        """Test the periodic table search logic"""
        print("\nTesting Periodic Table Filter...")
        
        # Test 1: Search by Group (Halogens)
        criteria = {'group': 17}
        results = periodic_table_service.search_elements(criteria)
        self.assertTrue(len(results) > 0)
        for r in results:
            # We need to fetch the full element to check group, 
            # as search_elements returns a simplified dict
            full_elem = periodic_table_service.get_element(r['symbol'])
            self.assertEqual(full_elem['group'], 17)
        print(f"✓ Group filter found {len(results)} elements")

        # Test 2: Search by Block (s-block)
        criteria = {'block': 's'}
        results = periodic_table_service.search_elements(criteria)
        self.assertTrue(len(results) > 0)
        print(f"✓ Block filter found {len(results)} elements")

        # Test 3: Multiple criteria (Non-metal in Period 2)
        # Note: search_elements logic needs to be checked if it supports 'is_nonmetal'
        # Looking at code: if 'is_metal' in criteria...
        # Let's test what's actually implemented
        criteria = {'period': 2, 'is_metal': False}
        results = periodic_table_service.search_elements(criteria)
        self.assertTrue(len(results) > 0)
        for r in results:
            self.assertIn(r['symbol'], ['C', 'N', 'O', 'F', 'Ne']) # B is metalloid
        print(f"✓ Multiple criteria filter found {len(results)} elements")

if __name__ == '__main__':
    unittest.main()
