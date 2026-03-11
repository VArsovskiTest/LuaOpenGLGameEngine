import { ContentChild, Directive, EmbeddedViewRef, EventEmitter, Input, OnChanges, Output, SimpleChanges, TemplateRef } from "@angular/core";
import { SnackbarModel } from "../models/miscelaneous.models";
import { MatSnackBar, MatSnackBarRef } from "@angular/material/snack-bar";
import { SnackbarFailTemplate } from "./templates/snackbar-fail-template";
import { SnackbarSuccessTemplate } from "./templates/snackbar-success-template";

@Directive({
  selector: '[appLoadSnackbar]',
  standalone: false
})
export class LoadSnackbarDirective implements OnChanges {
  @Input() model: SnackbarModel | null = null;
  @Output() showSuccess: EventEmitter<MatSnackBarRef<EmbeddedViewRef<any>>> = new EventEmitter();
  @Output() showError: EventEmitter<MatSnackBarRef<EmbeddedViewRef<any>>> = new EventEmitter();
  @ContentChild('appLoadSnackbarSuccessTemplate') successTemplate?: TemplateRef<SnackbarSuccessTemplate>;
  @ContentChild('appLoadSnackbarFailTemplate') failTemplate?: TemplateRef<SnackbarFailTemplate>;

  constructor(private snackBar: MatSnackBar) {}

  ngOnChanges(changes: SimpleChanges): void {
    alert(changes["model"] ? changes["model?.success"] : "no changes detected");
    if (changes["model"] && changes["model?.success"]) {
      if (this.model?.success)
        this.showSuccess.emit(this.snackBar.openFromTemplate(this.successTemplate!, { duration: 2000, }));
      else
        this.showError.emit(this.snackBar.openFromTemplate(this.failTemplate!, { duration: 2000, }));
    };
  }
}
