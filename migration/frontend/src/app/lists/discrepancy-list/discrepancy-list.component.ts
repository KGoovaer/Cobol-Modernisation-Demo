import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatCardModule } from '@angular/material/card';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { PaymentApiService } from '../../payment/payment-api.service';
import { Discrepancy, Page } from '../../core/models';

@Component({
  selector: 'app-discrepancy-list',
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule, MatPaginatorModule,
    MatCardModule, MatProgressBarModule,
  ],
  template: `
    <mat-card>
      <mat-card-header>
        <mat-card-title>Bank Account Discrepancy List</mat-card-title>
        <mat-card-subtitle>Payments where the provided IBAN differs from the member's known account</mat-card-subtitle>
      </mat-card-header>
      <mat-card-content>
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
          <ng-container matColumnDef="providedIban">
            <th mat-header-cell *matHeaderCellDef>Provided IBAN</th>
            <td mat-cell *matCellDef="let r" class="iban-cell highlight">{{ r.providedIban }}</td>
          </ng-container>
          <ng-container matColumnDef="knownIban">
            <th mat-header-cell *matHeaderCellDef>Known Account IBAN</th>
            <td mat-cell *matCellDef="let r" class="iban-cell">{{ r.knownIban }}</td>
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
    .full-width { width: 100%; }
    .iban-cell { font-family: monospace; }
    .highlight { color: #c62828; font-weight: 500; }
  `],
})
export class DiscrepancyListComponent implements OnInit {
  private readonly api = inject(PaymentApiService);

  readonly records = signal<Discrepancy[]>([]);
  readonly totalElements = signal(0);
  readonly loading = signal(false);

  displayedColumns = ['memberRnr', 'constantId', 'providedIban', 'knownIban', 'destinationMutuality', 'createdAt'];

  ngOnInit(): void { this.load(0); }

  load(pageIndex: number): void {
    this.loading.set(true);
    this.api.listDiscrepancies({ page: pageIndex, size: 25 }).subscribe({
      next: (page: Page<Discrepancy>) => {
        this.records.set(page.content);
        this.totalElements.set(page.totalElements);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }

  onPage(e: PageEvent): void { this.load(e.pageIndex); }
}
