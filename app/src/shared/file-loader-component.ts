import { Component, ElementRef, EventEmitter, inject, Input, Output, ViewChild } from '@angular/core';
import { formatSize } from './helpers/size-helper';
import { ActorsService } from '../services/actors-service';
import { BehaviorSubject } from 'rxjs';
import { ActorTypeEnum } from '../enums/enums';

@Component({
  selector: 'file-loader-component',
  imports: [],
  templateUrl: './file-loader-component.html',
})
export class FileLoaderComponent {
  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;
  @Input() sceneId: string | null = null;
  @Output() uploadImage: EventEmitter<{sceneId: string, actorType: ActorTypeEnum, file: File}> = new EventEmitter();

  protected selectedFile: BehaviorSubject<File | null> = new BehaviorSubject<File | null>(null);
  protected selectedFileName: string | null = null;

  constructor() { }

  protected imageSelected(imageInput: any) {
    const file: File = imageInput.target.files[0];
    this.selectedFile.next(file);
    this.selectedFileName = file.name + ` (${formatSize(file.size)})`;
    this.uploadImage.emit({sceneId: this.sceneId!, actorType: ActorTypeEnum.image, file: this.selectedFile.getValue()!});
  }
}
