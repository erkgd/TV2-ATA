export interface Image {
  id: string;
  _id?: string; // For backward compatibility with MongoDB IDs
  title: string;
  url: string;
  sourceUrl: string;
  thumbnailUrl: string;
  isTransparent: boolean;
  copyrightStatus: 'free' | 'commercial' | 'noncommercial' | 'modification' | 'unknown';
  width?: number;
  height?: number;
  fileSize?: number;
  fileType?: string;
  createdAt: string;
  likesCount?: number;
  commentsCount?: number;
  userLiked?: boolean;
  comments?: Comment[];
  similarImages?: Image[];
  likes?: Like[];
  source?: string;
}

export interface Like {
  id: string;
  user: string;
  image: string;
  createdAt: string;
}

export interface Comment {
  id: string;
  user: {
    id: string;
    username: string;
  };
  image: string;
  text: string;
  createdAt: string;
}

export interface SearchHistory {
  id: string;
  user: string;
  query: string;
  filters: {
    copyrightFilter: string;
    transparentOnly: boolean;
    useApi?: boolean;
  };
  createdAt: string;
}

export interface User {
  id: string;
  username: string;
  email?: string;
  avatar?: string;
  createdAt?: string;
}

export interface AuthResponse {
  id: string;
  username: string;
  token: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  pagination: {
    total: number;
    page: number;
    pages: number;
  };
}
