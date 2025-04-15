import jwt from "jsonwebtoken";
export const authenticateUser=(req,res,next)=>{
    const authHeader=req.header("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ message: "Access denied, No token provided" });
    }
        const token=authHeader.split(" ")[1];// Extract only the token part
        try {
            const decoded=jwt.verify(token,process.env.JWT_SECRET);
            req.user=decoded;
            next();  // continue to the next middleware or route handler
        } catch (error) {
            return res.status(401).json({ message: "Invalid token" });
        }
    };