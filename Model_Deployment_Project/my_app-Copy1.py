
import streamlit as st
import pandas as pd
import numpy as np
from PIL import Image
from sklearn.linear_model import Lasso
from sklearn.model_selection import train_test_split
from sklearn.compose import make_column_transformer
from sklearn.preprocessing import OneHotEncoder, MinMaxScaler
from sklearn.pipeline import Pipeline

df = pd.read_csv("without_outliers_autoscout.csv")   
features = ["make_model", "body_type", "km", "age", "gearing_type", "gears","price_€"]
df = df[features]

def add_bg_from_url():
    st.markdown(
         f"""
         <style>
         .stApp {{
             background-image: url("https://wallpaperaccess.com/full/239032.jpg");
             background-attachment: fixed;
             background-size: cover
         }}
         </style>
         """,
         unsafe_allow_html=True
     )

add_bg_from_url() 

st.title("Selling Price Predictor🚗")
st.markdown("**Are you planning to sell your car ?** ")
st.markdown("**Let's try evaluating the price** :grinning:")
    

 


import pickle

model = pickle.load(open('autoscout_deployment_project', 'rb'))


# Creating side bar 
st.sidebar.title("Select the features")
    
make_model = st.sidebar.selectbox("Make_Model", df.make_model.unique())

body_type = st.sidebar.selectbox("body_type", df.body_type.unique())

gearing_Type = st.sidebar.selectbox("Gearing_Type", df.gearing_type.unique())

age = st.sidebar.number_input("Age:",min_value=0, max_value=4)

# age = st.sidebar.selectbox("age", ("0","1", "2", "3"))

km = st.sidebar.slider("Km", 0.0, 317000.0)

Gears = st.sidebar.number_input("Gears",min_value=5, max_value=8)


dicti = {"make_model":[make_model],
         "body_type" : [body_type],
         "km" : [km],
         "age" : [age],
         "gearing_type" : [gearing_Type],
         "gears": [Gears]}

df2 = pd.DataFrame(dicti)

if st.button("See Dataset Sample"):
    st.write(df2)
   
if st.button("Predict"):
    prediction = model.predict(df2)
    st.success("Price of your car is €{}. ".format(int(prediction[0])))




    
    
    
    
    
