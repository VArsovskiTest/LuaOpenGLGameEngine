import { Injectable } from "@angular/core";
import { environment } from "../environments/environment";
import { HttpClient, HttpErrorResponse } from "@angular/common/http";
import { Observable, throwError } from "rxjs";
import { Actor } from "../models/actor.model";

@Injectable({providedIn: 'root'})
export class ActorsService {
    constructor(private http: HttpClient) { }
    private apiUrl = `${environment.apiUrl}/actors`;

    getActors(): Observable<Actor[]> {
        return this.http.get<Actor[]>(this.apiUrl);
    }

    getActorsForScene(id: string): Observable<Actor[]> {
        return this.http.get<Actor[]>(`${this.apiUrl}/${id}`);
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
