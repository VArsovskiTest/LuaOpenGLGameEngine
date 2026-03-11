import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpErrorResponse, HttpHeaders } from "@angular/common/http";
import { catchError, Observable, throwError, map } from "rxjs";
import { Actor } from "../store/actors/actor.model";

@Injectable({providedIn: 'root'})
export class ActorsService {
    constructor(private http: HttpClient) { }
    private apiUrl = `${environment.apiUrl}/actors`;

    private headers = new HttpHeaders();
    //.set('set-custom-headers-here', 'some-value')

    getActors(): Observable<Actor[]> {
        return this.http.get<Actor[]>(this.apiUrl, { headers: this.headers });
    }

    getActorsForScene(id: string): Observable<Actor[]> {
        return this.http.get<Actor[]>(`${this.apiUrl}/${id}`, { headers: this.headers });
    }

    uploadActor(sceneId: string, file: File): Observable<Actor> {
        const uploaded = this.http.post(`${this.apiUrl}/upload/${sceneId}`, { fileData: file }, { headers: this.headers }).pipe(
            map(response => response), //TODO: Show snackbar success,
            catchError(response => response) //TODO: Show snackbar fail
        );
        return uploaded as Observable<Actor>;
    }

    private handleError(error:HttpErrorResponse): Observable<never> {
        let errorMessage = "An unknown error occurred";
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
