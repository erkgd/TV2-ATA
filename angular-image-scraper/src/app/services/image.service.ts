import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import { Image, PaginatedResponse } from '../models';

@Injectable({
  providedIn: 'root'
})
export class ImageService {
  private apiUrl = `${environment.apiUrl}/images`;

  constructor(private http: HttpClient) { }

  getAllImages(page: number = 1, limit: number = 20): Observable<PaginatedResponse<Image>> {
    const params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());
    
    return this.http.get<any>(this.apiUrl + '/', { params }).pipe(
      map(resp => ({
        items: resp.items.map((item: any) => ({
          // normalize snake_case and camelCase from any backend
          id: String(item.id ?? item._id),
          title: item.title,
          url: item.url ?? item.url,
          sourceUrl: item.source_url ?? item.sourceUrl,
          thumbnailUrl: item.thumbnail_url ?? item.thumbnailUrl,
          isTransparent: item.is_transparent ?? item.isTransparent,
          copyrightStatus: item.copyright_status ?? item.copyrightStatus,
          width: item.width ?? item.width,
          height: item.height ?? item.height,
          fileSize: item.file_size ?? item.fileSize,
          fileType: item.file_type ?? item.fileType,
          createdAt: item.created_at ?? item.createdAt,
          likesCount: item.likes_count ?? item.likesCount ?? 0,
          commentsCount: item.comments_count ?? item.commentsCount ?? 0
        })),
        pagination: resp.pagination
      }))
    );
  }

  getImageById(id: string): Observable<Image> {
    return this.http.get<any>(`${this.apiUrl}/${id}/`).pipe(
      map(item => ({
        id: String(item.id ?? item._id),
        title: item.title,
        url: item.url,
        sourceUrl: item.source_url ?? item.sourceUrl,
        thumbnailUrl: item.thumbnail_url ?? item.thumbnailUrl,
        isTransparent: item.is_transparent ?? item.isTransparent,
        copyrightStatus: item.copyright_status ?? item.copyrightStatus,
        width: item.width,
        height: item.height,
        fileSize: item.file_size ?? item.fileSize,
        fileType: item.file_type ?? item.fileType,
        createdAt: item.created_at ?? item.createdAt,
        likesCount: item.likes_count ?? item.likesCount ?? 0,
        commentsCount: item.comments_count ?? item.commentsCount ?? (item.comments?.length ?? 0),
        userLiked: item.user_liked ?? item.userLiked ?? false,
        comments: item.comments || [],
        similarImages: item.similar_images ?? item.similarImages ?? []
      } as Image))
    );
  }

  createImage(image: Partial<Image>): Observable<Image> {
    return this.http.post<Image>(this.apiUrl, image);
  }
  updateImage(id: string, image: Partial<Image>): Observable<Image> {
    return this.http.put<Image>(`${this.apiUrl}/${id}/`, image);
  }

  deleteImage(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}/`);
  }

  likeImage(id: string): Observable<{ liked: boolean }> {
    return this.http.post<{ liked: boolean }>(`${this.apiUrl}/${id}/like/`, {});
  }

  unlikeImage(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}/like/`);
  }

  addComment(id: string, text: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/${id}/comment/`, { text });
  }
  /**
   * Fetch user profile including liked images, comments, and history
   */
  getUserProfile(): Observable<{ user: any; liked_images: Image[]; comments: any[]; search_history: any[] }> {
    return this.http.get<any>(`${environment.apiUrl}/users/profile/`);
  }

  /**
   * Get images the current user has liked
   */
  getUserFavorites(): Observable<Image[]> {
    return this.http.get<any>(`${environment.apiUrl}/users/profile/`).pipe(
      map(resp => resp.liked_images.map((item: any) => ({
        id: String(item.id),
        title: item.title,
        url: item.url,
        sourceUrl: item.source_url,
        thumbnailUrl: item.thumbnail_url,
        isTransparent: item.is_transparent,
        copyrightStatus: item.copyright_status,
        width: item.width,
        height: item.height,
        fileSize: item.file_size,
        fileType: item.file_type,
        createdAt: item.created_at,
        likesCount: item.likes_count,
        commentsCount: item.comments_count
      })))
    );
  }
}
