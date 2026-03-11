import { TemplateRef } from "@angular/core";
import { FormGroup } from "@angular/forms";

export class MenuItem {
    id: number = 0;
    name?: string;

    constructor(name: string, id: number) {
        this.id = id; this.name = name;        
    }
}

export class ActorBehavior {
    id: number = 0;
    name?: string;    
}

export interface DialogData {
  title?: string;
  message?: string;
  okText?: string;
  cancelText?: string;
  innerContent?: TemplateRef<any>;
  formGroup?: FormGroup;
}

export interface SnackbarModel {
    success?: boolean;
    successTitle?: string;
    errorTitle?: string;
    message?: string;
}
