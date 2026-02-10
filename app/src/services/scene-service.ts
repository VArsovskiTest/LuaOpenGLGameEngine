import { inject, Injectable } from "@angular/core";
import { catchError, map, Observable, of, throwError } from "rxjs";
import { Scene } from "../models/scene.model";
import { HttpClient, HttpErrorResponse } from "@angular/common/http";
import { environment } from "../environments/environment";

export interface SceneSvc extends Scene { createdAt?: string; updatedAt?: string; }
export interface SceneResponse { data: SceneSvc[]; }

@Injectable({providedIn: 'root'})
export class SceneService {
  private apiUrl = `${environment.apiUrl}/scenes`;
  constructor(private http: HttpClient) {}

  saveScene(sceneState: Partial<Scene>): Observable<Scene> {
    console.log("Saving: ", sceneState);
    // If it has an id → we assume it's an update (PUT), otherwise create new (POST)
    if (sceneState.id) {
      return this.http
        .put<Scene>(`${this.apiUrl}/${sceneState.id}`, sceneState)
        .pipe(catchError(this.handleError));
    } else {
      return this.http
        .post<Scene>(this.apiUrl, sceneState)
        .pipe(catchError(this.handleError));
    }
  }

  getScenes(): Observable<Scene[]> {
    return this.http.get<SceneResponse>(environment.apiUrl).pipe(map(response => response?.data || response),
    catchError(this.handleError));
  }

  createScene(scene: Omit<Scene, 'id'>): Observable<Scene> {
    return this.http.post<Scene>(this.apiUrl, scene)
      .pipe(catchError(this.handleError));
  }

  updateScene(id: string, changes: Partial<Scene>): Observable<Scene> {
    return this.http.put<Scene>(`${this.apiUrl}/${id}`, changes)
      .pipe(catchError(this.handleError));
  }

  private handleError(error: HttpErrorResponse): Observable<never> {
    let errorMessage = 'An unknown error occurred';

    if (error.error instanceof ErrorEvent) {
      errorMessage = `Error: ${error.error.message}`;
    } else {
      errorMessage = `Error Code: ${error.status}\nMessage: ${error.message}`;
      if (error.error?.message) {
        errorMessage += `\nServer: ${error.error.message}`;
      }
    }

    console.error(errorMessage);
    return throwError(() => new Error(errorMessage));
  }
}
