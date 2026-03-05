import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FileLoaderComponent } from './file-loader-component';

describe('FileLoaderComponent', () => {
  let component: FileLoaderComponent;
  let fixture: ComponentFixture<FileLoaderComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FileLoaderComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(FileLoaderComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
