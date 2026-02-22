import { InjectionToken } from '@angular/core';
import { FormGroup } from '@angular/forms';

export const CURRENT_FORM_GROUP = new InjectionToken<FormGroup>('CURRENT_FORM_GROUP');