import { Component } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-forbidden',
  standalone: true,
  imports: [MatCardModule, MatIconModule],
  template: `
    <mat-card style="max-width: 400px; margin: 48px auto; text-align: center;">
      <mat-card-content>
        <mat-icon style="font-size: 64px; color: #f44336;">block</mat-icon>
        <h2>Access Denied</h2>
        <p>You do not have permission to access this page.</p>
      </mat-card-content>
    </mat-card>
  `,
})
export class ForbiddenComponent {}
