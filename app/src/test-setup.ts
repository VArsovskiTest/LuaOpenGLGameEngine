// src/test-setup.ts
import 'zone.js';
import 'zone.js/testing';       // required for fakeAsync/tick etc.

import { getTestBed } from '@angular/core/testing';
import { BrowserTestingModule, platformBrowserTesting } from '@angular/platform-browser/testing';

// Initialize the Angular testing environment once
getTestBed().initTestEnvironment(
  BrowserTestingModule,
  platformBrowserTesting()
);
