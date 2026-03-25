import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { PaymentApiService } from '../../payment/payment-api.service';
import { PaymentRecord, Page } from '../../core/models';

@Component({
  selector: 'app-payment-list',
  standalone: true,
  imports: [
    CommonModule, FormsModule,
    MatTableModule, MatPaginatorModule,
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatButtonModule, MatCardModule, MatProgressBarModule,
  ],
  template: `
    <mat-card>
      <mat-card-header>
        <mat-card-title>Payment List</mat-card-title>
      </mat-card-header>
      <mat-card-content>

        <!-- Filters -->
        <div class="filter-row">
          <mat-form-field appearance="outline">
            <mat-label>Accounting Type</mat-label>
            <mat-select [(ngModel)]="filterAccountingType">
              <mat-option [value]="undefined">All</mat-option>
              <mat-option [value]="1">General</mat-option>
              <mat-option [value]="3">Flemish</mat-option>
              <mat-option [value]="4">Walloon</mat-option>
              <mat-option [value]="5">Brussels</mat-option>
              <mat-option [value]="6">German-speaking</mat-option>
            </mat-select>
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Mutuality Code</mat-label>
            <input matInput type="number" [(ngModel)]="filterMutualityCode" placeholder="e.g. 110" />
          </mat-form-field>

          <button mat-raised-button color="primary" (click)="load(0)">Filter</button>
          <button mat-button (click)="exportCsv()">Export CSV</button>
        </div>

        @if (loading()) { <mat-progress-bar mode="indeterminate" /> }

        <table mat-table [dataSource]="records()" class="full-width">
          <ng-container matColumnDef="memberRnr">
            <th mat-header-cell *matHeaderCellDef>RNR</th>
            <td mat-cell *matCellDef="let r">{{ r.memberRnr }}</td>
          </ng-container>
          <ng-container matColumnDef="memberName">
            <th mat-header-cell *matHeaderCellDef>Member</th>
            <td mat-cell *matCellDef="let r">{{ r.memberName }}</td>
          </ng-container>
          <ng-container matColumnDef="amountCents">
            <th mat-header-cell *matHeaderCellDef>Amount (€)</th>
            <td mat-cell *matCellDef="let r">{{ (r.amountCents / 100) | number:'1.2-2' }}</td>
          </ng-container>
          <ng-container matColumnDef="iban">
            <th mat-header-cell *matHeaderCellDef>IBAN</th>
            <td mat-cell *matCellDef="let r">{{ r.iban }}</td>
          </ng-container>
          <ng-container matColumnDef="bic">
            <th mat-header-cell *matHeaderCellDef>BIC</th>
            <td mat-cell *matCellDef="let r">{{ r.bic }}</td>
          </ng-container>
          <ng-container matColumnDef="bankRouting">
            <th mat-header-cell *matHeaderCellDef>Bank</th>
            <td mat-cell *matCellDef="let r">{{ r.bankRouting }}</td>
          </ng-container>
          <ng-container matColumnDef="paymentDescNl">
            <th mat-header-cell *matHeaderCellDef>Description (NL/FR)</th>
            <td mat-cell *matCellDef="let r">{{ r.paymentDescNl }} / {{ r.paymentDescFr }}</td>
          </ng-container>
          <ng-container matColumnDef="destinationMutuality">
            <th mat-header-cell *matHeaderCellDef>Mutuality</th>
            <td mat-cell *matCellDef="let r">{{ r.destinationMutuality }}</td>
          </ng-container>
          <ng-container matColumnDef="createdAt">
            <th mat-header-cell *matHeaderCellDef>Date</th>
            <td mat-cell *matCellDef="let r">{{ r.createdAt | date:'short' }}</td>
          </ng-container>

          <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
          <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
        </table>

        <mat-paginator
          [length]="totalElements()"
          [pageSize]="25"
          [pageSizeOptions]="[10, 25, 50]"
          (page)="onPage($event)"
          showFirstLastButtons />
      </mat-card-content>
    </mat-card>
  `,
  styles: [`
    .filter-row { display: flex; gap: 16px; align-items: center; flex-wrap: wrap; margin-bottom: 16px; }
    .filter-row mat-form-field { flex: 1 1 180px; }
    .full-width { width: 100%; }
  `],
})
export class PaymentListComponent implements OnInit {
  private readonly api = inject(PaymentApiService);

  readonly records = signal<PaymentRecord[]>([]);
  readonly totalElements = signal(0);
  readonly loading = signal(false);

  filterAccountingType: number | undefined;
  filterMutualityCode: number | undefined;

  displayedColumns = ['memberRnr', 'memberName', 'amountCents', 'iban', 'bic', 'bankRouting', 'paymentDescNl', 'destinationMutuality', 'createdAt'];

  ngOnInit(): void {
    this.load(0);
  }

  load(pageIndex: number): void {
    this.loading.set(true);
    const params: Record<string, string | number | boolean> = { page: pageIndex, size: 25 };
    if (this.filterAccountingType) params['accountingType'] = this.filterAccountingType;
    if (this.filterMutualityCode) params['mutualityCode'] = this.filterMutualityCode;

    this.api.listPayments(params).subscribe({
      next: (page: Page<PaymentRecord>) => {
        this.records.set(page.content);
        this.totalElements.set(page.totalElements);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }

  onPage(e: PageEvent): void {
    this.load(e.pageIndex);
  }

  exportCsv(): void {
    this.api.exportCsv().subscribe((blob) => {
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'payments.csv';
      a.click();
      URL.revokeObjectURL(url);
    });
  }
}
