from sqlalchemy import Column, Integer, String, Float, ForeignKey, JSON, DateTime, Boolean
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    permissions = Column(JSON) # e.g. {"can_approve_batches": true}

class Supplier(Base):
    __tablename__ = "suppliers"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    contact_info = Column(String)
    materials = relationship("Material", back_populates="supplier")

class Material(Base):
    __tablename__ = "materials"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    cas_number = Column(String, index=True)
    supplier_id = Column(Integer, ForeignKey("suppliers.id"))
    price_per_kg = Column(Float)
    inventory_level = Column(Float) # in kg
    ghs_tags = Column(JSON) # List of GHS codes e.g. ["H318", "H302"]
    
    supplier = relationship("Supplier", back_populates="materials")
    recipe_items = relationship("RecipeItem", back_populates="material")

class Recipe(Base):
    __tablename__ = "recipes"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    items = relationship("RecipeItem", back_populates="recipe")
    batch_logs = relationship("BatchLog", back_populates="recipe")
    cost_history = relationship("CostHistory", back_populates="recipe")

class RecipeItem(Base):
    __tablename__ = "recipe_items"
    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    material_id = Column(Integer, ForeignKey("materials.id"))
    percentage = Column(Float) # Percentage in the formula
    
    recipe = relationship("Recipe", back_populates="items")
    material = relationship("Material", back_populates="recipe_items")

class BatchLog(Base):
    __tablename__ = "batch_logs"
    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    batch_number = Column(String, unique=True)
    status = Column(String) # "Pending", "In Progress", "Completed", "Failed"
    produced_amount_kg = Column(Float)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    recipe = relationship("Recipe", back_populates="batch_logs")

class CostHistory(Base):
    __tablename__ = "cost_history"
    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    calculated_cost_per_kg = Column(Float)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    recipe = relationship("Recipe", back_populates="cost_history")
