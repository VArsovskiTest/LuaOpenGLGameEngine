import { Directive, input } from '@angular/core';
import { FormsModule } from '@angular/forms'

@Directive({
  selector: '[appFileLoaderDirective]',
})
export class FileLoaderDirective {

  constructor() { }

  protected selectedFile: File | null = null;
    onFileSelected(event: Event) {
      const input = event.target as HTMLInputElement;
      if (input.files && input.files.length) {
        this.selectedFile = input.files[0];
        this.readFile(this.selectedFile);
      }
    }

    private readFile(file: File){
      // reader.onload = (e) => { const content = e.target?.result as string; }
      return new FileReader().readAsText(file);
    }
}
