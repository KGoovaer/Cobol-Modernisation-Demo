import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { AuthService } from '../../auth/auth.service';

/**
 * T020 – Application shell: top nav bar with role-conditional links + router-outlet.
 */
@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    MatToolbarModule,
    MatButtonModule,
    MatSidenavModule,
    MatListModule,
    MatIconModule,
  ],
  template: `
    <mat-toolbar color="primary">
      <span>MYFIN – Payment Portal</span>
      <span class="spacer"></span>
      @if (auth.hasAnyRole('SUBMITTER')) {
        <a mat-button routerLink="/payment" routerLinkActive="active-link">
          Submit Payment
        </a>
      }
      @if (auth.hasAnyRole('SUBMITTER', 'READ_ONLY')) {
        <a mat-button routerLink="/lists/payments" routerLinkActive="active-link">
          Payment List
        </a>
        <a mat-button routerLink="/lists/rejections" routerLinkActive="active-link">
          Rejections
        </a>
        <a mat-button routerLink="/lists/discrepancies" routerLinkActive="active-link">
          Discrepancies
        </a>
      }
      @if (auth.hasAnyRole('ADMIN')) {
        <a mat-button routerLink="/admin" routerLinkActive="active-link">
          Admin
        </a>
      }
      <button mat-button (click)="logout()">
        <mat-icon>logout</mat-icon> Logout
      </button>
    </mat-toolbar>

    <main class="content">
      <router-outlet />
    </main>
  `,
  styles: [`
    .spacer { flex: 1 1 auto; }
    .content { padding: 24px; }
    .active-link { font-weight: bold; border-bottom: 2px solid white; }
  `],
})
export class ShellComponent implements OnInit {
  readonly auth = inject(AuthService);

  ngOnInit(): void {
    if (!this.auth.currentUser) {
      this.auth.me().subscribe();
    }
  }

  logout(): void {
    this.auth.logout().subscribe();
  }
}
