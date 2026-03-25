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
import { MatChipsModule } from '@angular/material/chips';
import { PaymentApiService } from '../../payment/payment-api.service';
import { RejectionRecord, Page } from '../../core/models';

@Component({
  selector: 'app-rejection-list',
  standalone: true,
  imports: [
    CommonModule, FormsModule,
    MatTableModule, MatPaginatorModule,
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatButtonModule, MatCardModule, MatProgressBarModule, MatChipsModule,
  ],
  template: `
    <mat-card>
      <mat-card-header>
        <mat-card-title>Rejection List</mat-card-title>
      </mat-card-header>
      <mat-card-content>

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
            <input matInput type="number" [(ngModel)]="filterMutualityCode" />
          </mat-form-field>
          <button mat-raised-button color="primary" (click)="load(0)">Filter</button>
        </div>

        @if (loading()) { <mat-progress-bar mode="indeterminate" /> }

        <table mat-table [dataSource]="records()" class="full-width">
          <ng-container matColumnDef="memberRnr">
            <th mat-header-cell *matHeaderCellDef>RNR</th>
            <td mat-cell *matCellDef="let r">{{ r.memberRnr }}</td>
          </ng-container>
          <ng-container matColumnDef="constantId">
            <th mat-header-cell *matHeaderCellDef>Constant ID</th>
            <td mat-cell *matCellDef="let r">{{ r.constantId }}</td>
          </ng-container>
          <ng-container matColumnDef="amountCents">
            <th mat-header-cell *matHeaderCellDef>Amount (€)</th>
            <td mat-cell *matCellDef="let r">{{ (r.amountCents / 100) | number:'1.2-2' }}</td>
          </ng-container>
          <ng-container matColumnDef="diagnostic">
            <th mat-header-cell *matHeaderCellDef>Reden / Raison</th>
            <td mat-cell *matCellDef="let r">
              <mat-chip-set>
                <mat-chip color="warn" highlighted>
                  {{ r.diagnosticNl }} / {{ r.diagnosticFr }}
                </mat-chip>
              </mat-chip-set>
            </td>
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
    .full-width { width: 100%; }
  `],
})
export class RejectionListComponent implements OnInit {
  private readonly api = inject(PaymentApiService);

  readonly records = signal<RejectionRecord[]>([]);
  readonly totalElements = signal(0);
  readonly loading = signal(false);

  filterAccountingType: number | undefined;
  filterMutualityCode: number | undefined;

  displayedColumns = ['memberRnr', 'constantId', 'amountCents', 'diagnostic', 'destinationMutuality', 'createdAt'];

  ngOnInit(): void { this.load(0); }

  load(pageIndex: number): void {
    this.loading.set(true);
    const params: Record<string, string | number | boolean> = { page: pageIndex, size: 25 };
    if (this.filterAccountingType) params['accountingType'] = this.filterAccountingType;
    if (this.filterMutualityCode) params['mutualityCode'] = this.filterMutualityCode;
    this.api.listRejections(params).subscribe({
      next: (page: Page<RejectionRecord>) => {
        this.records.set(page.content);
        this.totalElements.set(page.totalElements);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }

  onPage(e: PageEvent): void { this.load(e.pageIndex); }
}
