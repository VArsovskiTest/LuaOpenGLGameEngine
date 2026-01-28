import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms'

@Component({
  selector: 'app-file-loader-component',
  imports: [],
  providers: [FormsModule],
  templateUrl: './file-loader-component.html',
  styleUrl: './file-loader-component.scss',
})
export class FileLoaderComponent {
  protected selectedFile: File | null = null;
  onFileSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length) {
      this.selectedFile = input.files[0];
      this.readFile(this.selectedFile);
    }
  }

  readFile(file: File) {
    const reader = new FileReader();
    reader.onload = (e) => {
      const content = e.target?.result as string;
      console.log("File content: ", content);
    };

    reader.readAsText(file);
  }
}
