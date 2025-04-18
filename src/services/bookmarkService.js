import { Bookmark } from "../models/bookmark.model.js";

export const searchBookmarksService = async (req) => {
    // Extract search parameters from request query
    const { q, category, page = 1, limit = 10 } = req.query;
      
    // Get authenticated user's ID
    const userId = req.user._id;
      
    // Calculate documents to skip for pagination
    const skip = (page - 1) * limit;
    
    // BASE QUERY CONSTRUCTION
    // ----------------------
    // 1. Always filter by current user
    // 2. Add category filter if provided
    const baseQuery = {
      user: userId,
      ...(category && { category }) // Spread operator adds category only if it exists
    };
      
    // Initialize final query with base filters
    let finalQuery = baseQuery;
    
    // Initialize sortConfig with default sort
    let sortConfig = { createdAt: -1 }; // Default sort by newest first
    
    // QUERY PROCESSING
    // ----------------
    if (q) {
      // CASE 1: Proper search query (length > 2 characters)
      // Use MongoDB text search with relevance scoring
      if (q.length > 2) {
        // Text search for queries longer than 2 characters
        finalQuery = {
          ...baseQuery,
          $text: { $search: q }
        };
        // Update sort config for text search
        sortConfig = { score: { $meta: 'textScore' } };
      } else {
        // CASE 2: Short search query (1-2 characters)
        // Use regex matching instead of text search
        finalQuery = {
          ...baseQuery,
          $or: [
            { title: { $regex: q, $options: 'i' } },
            { tags: { $regex: q, $options: 'i' } }
          ]
        };
        // Keep default sort config
      }
    }
    
    // DATABASE OPERATIONS
    // -------------------
    // Use Promise.all to execute both operations in parallel
    const [results, totalCount] = await Promise.all([
      // 1. Get paginated results
      Bookmark.find(finalQuery)
        // Use the properly initialized sortConfig
        .sort(sortConfig)
        .skip(skip)              // Pagination skip
        .limit(parseInt(limit))  // Number of results per page
        .select('-__v')          // Exclude version key
        .lean(),                 // Return plain JS objects (faster)
        
      // 2. Get total matching documents count
      Bookmark.countDocuments(finalQuery)
    ]);
    
    // RESPONSE FORMATTING
    // -------------------
    return {
      total: totalCount,         // Total matching documents
      page: parseInt(page),      // Current page number
      totalPages: Math.ceil(totalCount / limit), // Total number of pages
      limit: parseInt(limit),    // Results per page
      bookmarks: results         // Paginated results
    };
  };