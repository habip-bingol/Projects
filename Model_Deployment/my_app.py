import streamlit as st
import pandas as pd
import numpy as np
from PIL import Image
import pickle
import datetime 
import streamlit.components.v1 as components
import base64


def add_bg_from_file(image_path):
    image_data = open(image_path, 'rb').read()
    st.markdown(
         f"""
         <style>
         .stApp {{
             background-image: url("data:image/png;base64,{base64.b64encode(image_data).decode()}") !important;
             background-attachment: fixed;
             background-size: 100%;
         }}
         </style>
         """,
         unsafe_allow_html=True
     )


add_bg_from_file("fixed.png")




html_temp = """
<div style="background-color:green;padding:1.5px">
<h1 style="color:white;text-align:center;">Select Car Features</h1>
</div><br>"""
st.sidebar.markdown(html_temp,unsafe_allow_html=True)

html_temp2 = """
<div style="background-color:green;padding:1.5px">
<h1 style="color:white;text-align:center;">Car Price Prediction App</h1>
</div><br>"""
st.markdown(html_temp2,unsafe_allow_html=True)

st.success("Click the arrow in the upper left corner to open the sidebar and select features of the car.")

df = pd.read_csv("sahibinden_bot_result.csv", delimiter=";", dtype={"painted_parts": str, "changed_parts": str})
# st.write(df.head(1))

df_cleaned=pd.read_csv("cleaned_car_data.csv", index_col=0)
# st.write(df_cleaned.head(1))

# if st.button("See Dataset Sample"):
#     st.write(df_cleaned.sample(5))

# brand_model
sorted_brands = sorted(df.brand.unique())
selected_brand = st.sidebar.selectbox("Brand", sorted_brands)
sorted_models = sorted(df.loc[df.brand == selected_brand].model.unique())
selected_model = st.sidebar.selectbox("Model", sorted_models)
brand_model = selected_brand+" "+selected_model

# age 
min_year = 2000
max_year = df.year.max()
year_range = np.arange(int(min_year), int(max_year)+1)
selected_year = st.sidebar.selectbox("Select a year", year_range, index=len(year_range)-1)
age = datetime.datetime.now().year - selected_year


# km 
km = st.sidebar.number_input("Kilometer", min_value=0, max_value=1000000, value=0, step=1000)

# Transmission
transmission = st.sidebar.selectbox("Displacement", ('Otomatik', 'Manuel', 'Yarı Otomatik'))

#fuel_type
fuel_type = st.sidebar.selectbox("Fuel Type", df.fuel_Type.unique())

#body_type
sorted_bodies = sorted([a for a in df.body_type.unique() if a != "Belirtilmemiş"])
body_type = st.sidebar.selectbox("Body Type", sorted_bodies)

# power 
min_power = df_cleaned.power.min()
max_power = df_cleaned.power.max()
power = st.sidebar.number_input("Select a power", min_value=int(min_power), max_value=int(max_power), value=100, step=1)


# displacement 
# power 
min_dis = df_cleaned.displacement.min()
max_dis = df_cleaned.displacement.max()
displacement = st.sidebar.number_input("Enter displacement", min_value=(min_dis), max_value=(max_dis), step=0.1)

# drivewheel
drivewheel = st.sidebar.selectbox("Select Drivewheel", df.drivewheel.unique())

# hard_hit
hard_hit = st.sidebar.selectbox("Is the vehicle heavily damaged?", ("No", "Yes"))
if hard_hit == "Yes":
    hard_hit = 1
else : 
    hard_hit=0
  
 # parts
parts = ["front-bumper", "front-hood" ,"roof", "rear-hood","rear-bumper","front-left-mudguard" ,
         "front-right-mudguard", "front-left-door", "front-right-door", "rear-right-door", 
         "rear-left-door","rear-left-mudguard", "rear-right-mudguard"]

painted_parts = st.sidebar.multiselect("Select the painted parts", parts)
changed_parts = st.sidebar.multiselect("Select the changed parts", parts)

def get_painted_part_dict(parts, painted_parts):
    part_dict = {}
    for part in parts:
        painted_part = "painted_" + part
        if part in painted_parts:
            part_dict[painted_part] = 1
        else:
            part_dict[painted_part] = 0       
    return part_dict

def get_changed_part_dict(parts, changed_parts):
    part_dict = {}
    for part in parts:
        changed_part = "changed_" + part
        if part in changed_parts:
            part_dict[changed_part] = 1
        else:
            part_dict[changed_part] = 0       
    return part_dict

painted_part_dict = get_painted_part_dict(parts, painted_parts)
changed_part_dict = get_changed_part_dict(parts, changed_parts)

df_parts = pd.DataFrame({**painted_part_dict, **changed_part_dict}, index=[0])


new_data = {"brand_model" : brand_model,
            "km" : km,
            "fuel_type" : fuel_type,
            "transmission" : transmission,
            "body_type" : body_type,
            "power" : power,
            "age" : age,
            "displacement" : displacement,
            "drivewheel" : drivewheel,
            "hard_hit" : hard_hit
            
}
df = pd.DataFrame([new_data])

merged_df = pd.concat([df, df_parts], axis=1)
st.write(merged_df)


final_model = pickle.load(open("model.pkl", "rb"))
# st.info("**Check the features you selected from the table above. If correct, press the Predict button.**")

html_temp3 = """
<div style="background-color:green;padding:1.5px">
<h6 style="color:white;text-align:center;">Check the features you selected from the table above. If correct, press the Predict button.</h6>
</div><br>"""
st.markdown(html_temp3,unsafe_allow_html=True)

if st.button("Predict"):
    prediction = final_model.predict(merged_df)
    html_temp4 = f"""
    <div style="background-color:green;padding:1.5px">
        <h6 style="color:white;text-align:center;">Your Car is :  {round(prediction[0])} ₺</h6>
    </div>"""
    st.markdown(html_temp4,unsafe_allow_html=True)


    