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
  
    // QUERY PROCESSING
    // ----------------
    if (q && q.length > 2) {
      // CASE 1: Proper search query (length > 2 characters)
      // Use MongoDB text search with relevance scoring
      finalQuery = { 
        ...baseQuery,
        $text: { $search: q }, // MongoDB text search operator
        
        // This OR condition combines text matches with partial matches
        // Note: $text search already includes matches from indexed fields (title, tags, etc.)
        $or: [
          { score: { $meta: 'textScore' } }, // Matches documents with text search score
          { 
            $or: [ // Fallback partial matches
              { title: { $regex: q, $options: 'i' } }, // Case-insensitive regex
              { tags: { $regex: q, $options: 'i' } }
            ]
          }
        ]
      };
    } else if (q) {
      // CASE 2: Short search query (1-2 characters)
      // Use regex matching instead of text search
      finalQuery = {
        ...baseQuery,
        $or: [
          { title: { $regex: q, $options: 'i' } }, // Partial match in title
          { tags: { $regex: q, $options: 'i' } }   // Partial match in tags
        ]
      };
    }
  
    // DATABASE OPERATIONS
    // -------------------
    // Use Promise.all to execute both operations in parallel
    const [results, totalCount] = await Promise.all([
      // 1. Get paginated results
      Bookmark.find(finalQuery)
        // Sort by relevance score if using text search, else by creation date
        .sort(q && q.length > 2 ? 
          { score: { $meta: 'textScore' } } : // Text search relevance
          { createdAt: -1 } // Newest first
        )
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