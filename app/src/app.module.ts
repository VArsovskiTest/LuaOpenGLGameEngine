import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BrowserModule } from '@angular/platform-browser';
import { AppComponent } from './components/app-component/app-component'; // Confirm this path
import { EditorMenuComponent } from './components/editor-menu-component/editor-menu-component'; // Adjust if necessary

@NgModule({
  declarations: [
    // AppComponent,
    // EditorMenuComponent,
  ],
  imports: [
    BrowserModule, CommonModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
``