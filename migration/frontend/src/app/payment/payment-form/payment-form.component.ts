import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatDividerModule } from '@angular/material/divider';
import { MatIconModule } from '@angular/material/icon';
import { PaymentApiService } from '../payment-api.service';
import { PaymentResult } from '../../core/models';

@Component({
  selector: 'app-payment-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatCardModule,
    MatProgressSpinnerModule,
    MatDividerModule,
    MatIconModule,
  ],
  template: `
    <mat-card class="form-card">
      <mat-card-header>
        <mat-card-title>Submit Manual Payment</mat-card-title>
      </mat-card-header>
      <mat-card-content>
        <form [formGroup]="form" (ngSubmit)="submit()">

          <div class="form-row">
            <mat-form-field appearance="outline">
              <mat-label>Member National Registry Number</mat-label>
              <input matInput formControlName="memberRnr" type="number" placeholder="12345678901" />
              <mat-error *ngIf="form.get('memberRnr')?.hasError('required')">Required</mat-error>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>Destination Mutuality (101–169)</mat-label>
              <input matInput formControlName="destinationMutuality" type="number" />
              <mat-error *ngIf="form.get('destinationMutuality')?.invalid">101–169 required</mat-error>
            </mat-form-field>
          </div>

          <div class="form-row">
            <mat-form-field appearance="outline">
              <mat-label>Constant Identifier</mat-label>
              <input matInput formControlName="constantId" maxlength="10" />
              <mat-error *ngIf="form.get('constantId')?.hasError('required')">Required</mat-error>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>Sequence Number</mat-label>
              <input matInput formControlName="sequenceNo" maxlength="4" />
            </mat-form-field>
          </div>

          <div class="form-row">
            <mat-form-field appearance="outline">
              <mat-label>Amount (€)</mat-label>
              <input matInput formControlName="amountEuros" type="number" step="0.01" min="0.01" />
              <mat-hint>Enter in euros (e.g. 125.00)</mat-hint>
              <mat-error *ngIf="form.get('amountEuros')?.invalid">Valid amount required</mat-error>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>Currency</mat-label>
              <mat-select formControlName="currency">
                <mat-option value="E">EUR (€)</mat-option>
                <mat-option value="B">BEF (legacy)</mat-option>
              </mat-select>
            </mat-form-field>
          </div>

          <div class="form-row">
            <mat-form-field appearance="outline">
              <mat-label>Payment Description Code (1–99)</mat-label>
              <input matInput formControlName="paymentDescCode" type="number" min="1" max="99" />
              <mat-error *ngIf="form.get('paymentDescCode')?.invalid">1–99 required</mat-error>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>IBAN</mat-label>
              <input matInput formControlName="iban" maxlength="34" placeholder="BE68539007547034" />
              <mat-error *ngIf="form.get('iban')?.hasError('required')">Required</mat-error>
            </mat-form-field>
          </div>

          <div class="form-row">
            <mat-form-field appearance="outline">
              <mat-label>Payment Method</mat-label>
              <mat-select formControlName="paymentMethod">
                <mat-option value=" ">SEPA Transfer</mat-option>
                <mat-option value="C">Circular Cheque (C)</mat-option>
                <mat-option value="D">Circular Cheque (D)</mat-option>
                <mat-option value="E">Circular Cheque (E)</mat-option>
                <mat-option value="F">Circular Cheque (F)</mat-option>
              </mat-select>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>Accounting Type</mat-label>
              <mat-select formControlName="accountingType">
                <mat-option [value]="1">1 – General</mat-option>
                <mat-option [value]="3">3 – Flemish</mat-option>
                <mat-option [value]="4">4 – Walloon</mat-option>
                <mat-option [value]="5">5 – Brussels</mat-option>
                <mat-option [value]="6">6 – German-speaking</mat-option>
              </mat-select>
            </mat-form-field>
          </div>

          <div class="actions">
            <button mat-raised-button color="primary" type="submit"
                    [disabled]="form.invalid || loading()">
              Submit Payment
            </button>
            @if (loading()) {
              <mat-spinner diameter="24" />
            }
          </div>
        </form>

        @if (result()) {
          <mat-divider style="margin: 24px 0" />
          <div [class]="result()!.status === 'ACCEPTED' ? 'result-accepted' : 'result-rejected'">
            @if (result()!.status === 'ACCEPTED') {
              <mat-icon>check_circle</mat-icon>
              <strong>Payment accepted.</strong>
              <span>Reference: {{ result()!.requestId }}</span>
            } @else {
              <mat-icon>cancel</mat-icon>
              <strong>Payment rejected.</strong>
              <span>
                <strong>Reden / Raison:</strong>
                {{ result()!.diagnosticNl }} / {{ result()!.diagnosticFr }}
              </span>
            }
          </div>
        }

        @if (serviceError()) {
          <div class="result-rejected">
            <mat-icon>warning</mat-icon>
            <span>{{ serviceError() }}</span>
          </div>
        }
      </mat-card-content>
    </mat-card>
  `,
  styles: [`
    .form-card { max-width: 900px; margin: 0 auto; }
    .form-row { display: flex; gap: 16px; flex-wrap: wrap; }
    .form-row mat-form-field { flex: 1 1 300px; }
    .actions { display: flex; align-items: center; gap: 16px; margin-top: 16px; }
    .result-accepted, .result-rejected {
      display: flex; align-items: flex-start; gap: 12px; padding: 16px;
      border-radius: 4px; flex-wrap: wrap;
    }
    .result-accepted { background: #e8f5e9; color: #2e7d32; }
    .result-rejected { background: #ffebee; color: #c62828; }
    mat-icon { font-size: 28px; height: 28px; width: 28px; }
  `],
})
export class PaymentFormComponent {
  private readonly paymentApi = inject(PaymentApiService);
  private readonly fb = inject(FormBuilder);

  readonly loading = signal(false);
  readonly result = signal<PaymentResult | null>(null);
  readonly serviceError = signal<string | null>(null);

  readonly form = this.fb.group({
    memberRnr: [null as number | null, [Validators.required, Validators.min(1)]],
    destinationMutuality: [null as number | null, [Validators.required, Validators.min(101), Validators.max(169)]],
    constantId: ['', [Validators.required, Validators.maxLength(10)]],
    sequenceNo: [''],
    amountEuros: [null as number | null, [Validators.required, Validators.min(0.01)]],
    currency: ['E'],
    paymentDescCode: [null as number | null, [Validators.required, Validators.min(1), Validators.max(99)]],
    iban: ['', [Validators.required, Validators.maxLength(34)]],
    paymentMethod: [' '],
    accountingType: [1],
  });

  submit(): void {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.result.set(null);
    this.serviceError.set(null);

    const v = this.form.value;
    const amountCents = Math.round((v.amountEuros ?? 0) * 100);

    this.paymentApi.submit({
      memberRnr: v.memberRnr!,
      destinationMutuality: v.destinationMutuality!,
      constantId: v.constantId!,
      sequenceNo: v.sequenceNo ?? undefined,
      amountCents,
      currency: (v.currency ?? 'E') as 'E' | 'B',
      paymentDescCode: v.paymentDescCode!,
      iban: v.iban!,
      paymentMethod: (v.paymentMethod ?? ' ') as ' ' | 'C',
      accountingType: (v.accountingType ?? 1) as 1,
    }).subscribe({
      next: (res) => {
        this.result.set(res);
        this.loading.set(false);
      },
      error: (err) => {
        const msg = err?.error?.error ?? 'An unexpected error occurred.';
        this.serviceError.set(msg);
        this.loading.set(false);
      },
    });
  }
}
