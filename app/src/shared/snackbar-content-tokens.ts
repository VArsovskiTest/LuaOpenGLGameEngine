import { InjectionToken } from "@angular/core";
import { SnackbarModel } from "../models/miscelaneous.models";

export const SNACKBAR_CONTENT_TOKEN = new InjectionToken<SnackbarModel>('CURRENT_SNACKBAR_CONTENT');
