import { Component, ElementRef, ViewChild } from '@angular/core';

@Component({
  selector: 'file-loader-component',
  imports: [],
  templateUrl: './file-loader-component.html',
  styleUrl: './file-loader-component.scss',
})
export class FileLoaderComponent {
  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;
  triggerFileInput() {
    this.fileInput.nativeElement.click();
  }
}
