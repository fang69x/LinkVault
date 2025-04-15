import mongoose from "mongoose";

export const connectDB=async ()=>{
    try {
        const connectionInstance=await mongoose.connect(`${process.env.MONGODB_URI}`)
        console.log(connectionInstance.connection.host);
        console.log("Database connected");
        
        
    } catch (error) {
        console.log(error);
        
        process.exit(1);
    }
};