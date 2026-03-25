import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatDialogModule, MatDialog } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatChipsModule } from '@angular/material/chips';
import { AdminApiService } from '../admin-api.service';
import { UserAdminDto } from '../../core/models';

@Component({
  selector: 'app-user-management',
  standalone: true,
  imports: [
    CommonModule, ReactiveFormsModule,
    MatTableModule, MatCardModule,
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatButtonModule, MatDialogModule, MatIconModule,
    MatProgressBarModule, MatChipsModule,
  ],
  template: `
    <mat-card>
      <mat-card-header>
        <mat-card-title>User Management</mat-card-title>
      </mat-card-header>
      <mat-card-content>
        @if (loading()) { <mat-progress-bar mode="indeterminate" /> }

        <!-- Create user form -->
        <mat-card class="create-card">
          <mat-card-subtitle>Create New User</mat-card-subtitle>
          <form [formGroup]="createForm" (ngSubmit)="createUser()">
            <div class="form-row">
              <mat-form-field appearance="outline">
                <mat-label>Username</mat-label>
                <input matInput formControlName="username" />
                <mat-error *ngIf="createForm.get('username')?.invalid">3–100 characters required</mat-error>
              </mat-form-field>

              <mat-form-field appearance="outline">
                <mat-label>Password</mat-label>
                <input matInput type="password" formControlName="password" />
                <mat-error *ngIf="createForm.get('password')?.invalid">Min 8 characters</mat-error>
              </mat-form-field>

              <mat-form-field appearance="outline">
                <mat-label>Role</mat-label>
                <mat-select formControlName="role">
                  <mat-option value="SUBMITTER">Submitter</mat-option>
                  <mat-option value="READ_ONLY">Read-Only</mat-option>
                  <mat-option value="ADMIN">Admin</mat-option>
                </mat-select>
              </mat-form-field>

              <mat-form-field appearance="outline">
                <mat-label>Mutuality Codes (comma-separated)</mat-label>
                <input matInput formControlName="mutualityCodesRaw" placeholder="101,110,120" />
              </mat-form-field>
            </div>

            @if (createError()) {
              <div class="error-msg">{{ createError() }}</div>
            }
            <button mat-raised-button color="primary" type="submit" [disabled]="createForm.invalid || loading()">
              Create User
            </button>
          </form>
        </mat-card>

        <!-- Users table -->
        <table mat-table [dataSource]="users()" class="full-width" style="margin-top: 24px">
          <ng-container matColumnDef="username">
            <th mat-header-cell *matHeaderCellDef>Username</th>
            <td mat-cell *matCellDef="let u">{{ u.username }}</td>
          </ng-container>
          <ng-container matColumnDef="role">
            <th mat-header-cell *matHeaderCellDef>Role</th>
            <td mat-cell *matCellDef="let u">{{ u.role }}</td>
          </ng-container>
          <ng-container matColumnDef="mutualityCodes">
            <th mat-header-cell *matHeaderCellDef>Mutuality Codes</th>
            <td mat-cell *matCellDef="let u">{{ u.mutualityCodes.join(', ') || '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="active">
            <th mat-header-cell *matHeaderCellDef>Active</th>
            <td mat-cell *matCellDef="let u">
              <mat-chip [color]="u.active ? 'primary' : 'warn'" highlighted>
                {{ u.active ? 'Active' : 'Inactive' }}
              </mat-chip>
            </td>
          </ng-container>
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef>Actions</th>
            <td mat-cell *matCellDef="let u">
              @if (u.active) {
                <button mat-button color="warn" (click)="deactivate(u)">Deactivate</button>
              }
              <button mat-button (click)="resetPassword(u)">Reset Password</button>
            </td>
          </ng-container>

          <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
          <tr mat-row *matRowDef="let row; columns: displayedColumns;" [class.inactive-row]="!row.active"></tr>
        </table>
      </mat-card-content>
    </mat-card>
  `,
  styles: [`
    .create-card { margin-bottom: 24px; padding: 16px; background: #f5f5f5; }
    .form-row { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 12px; }
    .form-row mat-form-field { flex: 1 1 200px; }
    .full-width { width: 100%; }
    .inactive-row { opacity: 0.5; }
    .error-msg { color: #c62828; margin-bottom: 8px; }
  `],
})
export class UserManagementComponent implements OnInit {
  private readonly adminApi = inject(AdminApiService);
  private readonly fb = inject(FormBuilder);

  readonly users = signal<UserAdminDto[]>([]);
  readonly loading = signal(false);
  readonly createError = signal<string | null>(null);

  displayedColumns = ['username', 'role', 'mutualityCodes', 'active', 'actions'];

  readonly createForm = this.fb.group({
    username: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(100)]],
    password: ['', [Validators.required, Validators.minLength(8)]],
    role: ['SUBMITTER', Validators.required],
    mutualityCodesRaw: [''],
  });

  ngOnInit(): void { this.loadUsers(); }

  loadUsers(): void {
    this.loading.set(true);
    this.adminApi.listUsers().subscribe({
      next: (list) => { this.users.set(list); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  createUser(): void {
    if (this.createForm.invalid) return;
    this.createError.set(null);
    const v = this.createForm.value;
    const codes = (v.mutualityCodesRaw ?? '').split(',')
      .map(s => parseInt(s.trim()))
      .filter(n => !isNaN(n) && n >= 101 && n <= 169);

    this.adminApi.createUser({
      username: v.username!,
      password: v.password!,
      role: v.role as 'SUBMITTER' | 'READ_ONLY' | 'ADMIN',
      mutualityCodes: codes,
    }).subscribe({
      next: () => { this.createForm.reset({ role: 'SUBMITTER' }); this.loadUsers(); },
      error: (err) => this.createError.set(err?.error?.error ?? 'Failed to create user'),
    });
  }

  deactivate(user: UserAdminDto): void {
    if (!confirm(`Deactivate user "${user.username}"?`)) return;
    this.adminApi.deactivateUser(user.id).subscribe({
      next: () => this.loadUsers(),
      error: (err) => alert(err?.error?.error ?? 'Failed to deactivate user'),
    });
  }

  resetPassword(user: UserAdminDto): void {
    const pw = prompt(`New password for "${user.username}" (min 8 chars):`);
    if (!pw || pw.length < 8) { alert('Password too short.'); return; }
    this.adminApi.resetPassword(user.id, pw).subscribe({
      next: () => alert('Password reset successfully.'),
      error: (err) => alert(err?.error?.error ?? 'Failed to reset password'),
    });
  }
}
