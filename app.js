import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import authRoutes from "./src/routes/authRoutes.js"; 
import bookmarkRoutes from "./src/routes/bookmarkRoutes.js"; 

dotenv.config();
const app=express();

//Middleware
app.use(cors());
app.use(express.json());

//routes

app.use("/api/auth",authRoutes);
app.use("/api/bookmarks",bookmarkRoutes);

export default app;