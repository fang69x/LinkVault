import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import authRoutes from "./src/routes/authRoutes.js"; 


dotenv.config();
const app=express();

//Middleware
app.use(cors());
app.use(express.json());

//routes

app.use("/api/auth",authRoutes);

export default app;