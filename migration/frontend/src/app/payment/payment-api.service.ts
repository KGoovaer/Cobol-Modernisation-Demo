import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../core/api.service';
import {
  Discrepancy,
  Page,
  PaymentRecord,
  PaymentResult,
  PaymentSubmitRequest,
  RejectionRecord,
} from '../core/models';

@Injectable({ providedIn: 'root' })
export class PaymentApiService {
  private readonly api = inject(ApiService);

  submit(req: PaymentSubmitRequest): Observable<PaymentResult> {
    return this.api.post<PaymentResult>('/api/payments', req);
  }

  listPayments(params?: Record<string, string | number | boolean>): Observable<Page<PaymentRecord>> {
    return this.api.get<Page<PaymentRecord>>('/api/payments', params);
  }

  getPayment(id: string): Observable<PaymentRecord> {
    return this.api.get<PaymentRecord>(`/api/payments/${id}`);
  }

  search(constantId?: string, sequenceNo?: string): Observable<PaymentRecord | null> {
    const p: Record<string, string> = {};
    if (constantId) p['constantId'] = constantId;
    if (sequenceNo) p['sequenceNo'] = sequenceNo;
    return this.api.get<PaymentRecord | null>('/api/payments/search', p);
  }

  exportCsv(): Observable<Blob> {
    return this.api.getBlob('/api/payments/export/csv');
  }

  listRejections(params?: Record<string, string | number | boolean>): Observable<Page<RejectionRecord>> {
    return this.api.get<Page<RejectionRecord>>('/api/rejections', params);
  }

  listDiscrepancies(params?: Record<string, string | number | boolean>): Observable<Page<Discrepancy>> {
    return this.api.get<Page<Discrepancy>>('/api/discrepancies', params);
  }
}
