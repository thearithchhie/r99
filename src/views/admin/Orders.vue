<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4 flex-wrap gap-3">
        <Tabs v-model="activeTab" @update:model-value="onTabChange">
          <TabsList>
            <TabsTrigger v-for="t in TABS" :key="t.value" :value="t.value">{{ t.label }}</TabsTrigger>
          </TabsList>
        </Tabs>
        <Button size="sm" @click="openCreate"><Plus :size="14" /> New order</Button>
      </div>

      <div v-if="loadError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4">
        <AlertTriangle :size="14" class="shrink-0" />{{ loadError }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>#</TableHead>
              <TableHead>Customer</TableHead>
              <TableHead>Staff</TableHead>
              <TableHead>Source</TableHead>
              <TableHead>Payment</TableHead>
              <TableHead>Items</TableHead>
              <TableHead class="text-right">Total</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Date</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 8" :key="'s'+n">
              <TableCell colspan="9"><div class="h-4 rounded bg-muted animate-pulse w-full" /></TableCell>
            </TableRow>
            <template v-if="!loading">
              <TableRow
                v-for="o in orders"
                :key="o.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="openDetail(o)"
              >
                <TableCell class="font-mono text-[12px] text-muted-foreground">{{ o.id }}</TableCell>
                <TableCell>
                  <div class="font-medium">{{ o.customer_name }}</div>
                  <div class="font-mono text-[11.5px] text-muted-foreground">{{ o.customer_phone }}</div>
                </TableCell>
                <TableCell class="text-[13px] text-muted-foreground">{{ o.staff_name ?? '—' }}</TableCell>
                <TableCell>
                  <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold bg-muted text-muted-foreground">
                    {{ o.page_source }}
                  </span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[13px]">
                  {{ paymentLabel(o.payment_type) }}
                  <span v-if="o.payment_method" class="text-muted-foreground/60"> · {{ o.payment_method }}</span>
                </TableCell>
                <TableCell class="text-muted-foreground">{{ o.items?.length ?? 0 }}</TableCell>
                <TableCell class="text-right font-medium">{{ money(o.total_amount) }}</TableCell>
                <TableCell><OrderStatusBadge :status="o.status" /></TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(o.created_at) }}</TableCell>
              </TableRow>
              <TableRow v-if="orders.length === 0 && !loadError">
                <TableCell colspan="9" class="text-center text-muted-foreground py-12 text-sm">No orders found.</TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <div v-if="meta && meta.total_pages > 1" class="flex justify-center mt-4">
        <Pagination :page="currentPage" :total-pages="meta.total_pages" @change="changePage" />
      </div>
    </div>

    <!-- Order detail sheet -->
    <Sheet :open="!!selectedOrder" @update:open="(v) => !v && (selectedOrder = null)">
      <SheetContent class="overflow-y-auto p-0 w-[520px] sm:max-w-[520px]">
        <div v-if="selectedOrder" class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <div>
              <span class="text-[15px] font-semibold">Order #{{ selectedOrder.id }}</span>
              <p class="text-[12.5px] text-muted-foreground mt-0.5">{{ selectedOrder.customer_name }}</p>
            </div>
            <div class="flex items-center gap-1">
              <Button variant="ghost" size="icon" class="h-8 w-8" @click="printOpen = true"><Printer :size="15" /></Button>
              <Button variant="ghost" size="icon" class="h-8 w-8" @click="selectedOrder = null"><X :size="18" /></Button>
            </div>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">

            <!-- Status + info -->
            <div class="flex flex-col gap-0 rounded-lg border border-border overflow-hidden">
              <div class="flex items-center px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Status</span>
                <OrderStatusBadge :status="selectedOrder.status" />
              </div>
              <div v-if="selectedOrder.return_reason" class="flex items-center px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Return reason</span>
                <span class="text-[13px]">{{ selectedOrder.return_reason.replace(/_/g, " ") }}</span>
              </div>
              <div class="flex items-center px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Phone</span>
                <span class="font-mono text-[13px]">{{ selectedOrder.customer_phone }}</span>
              </div>
              <div class="flex items-center px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Source</span>
                <span class="text-[13px]">{{ selectedOrder.page_source }}</span>
              </div>
              <div class="flex items-center px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Payment</span>
                <span class="text-[13px]">{{ paymentLabel(selectedOrder.payment_type) }}<span v-if="selectedOrder.payment_method"> · {{ selectedOrder.payment_method }}</span></span>
              </div>
              <div class="flex items-center px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Promotion</span>
                <span class="text-[13px]">{{ selectedOrder.is_promotion ? "Yes (no delivery fee)" : "No" }}</span>
              </div>
              <div v-if="selectedOrder.note" class="flex items-start px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0 pt-0.5">Note</span>
                <span class="text-[13px]">{{ selectedOrder.note }}</span>
              </div>
              <div class="flex items-center px-4 py-3">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Staff</span>
                <span class="text-[13px]">{{ selectedOrder.staff_name }}</span>
              </div>
            </div>

            <!-- Items -->
            <div>
              <p class="text-[13px] font-semibold mb-2">Items</p>
              <div class="flex flex-col gap-1.5">
                <div v-for="item in selectedOrder.items" :key="item.product_id"
                  class="flex items-center justify-between px-3 py-2.5 rounded-lg bg-muted/40 text-[13px]">
                  <div>
                    <div class="font-medium">{{ item.product_name }}</div>
                    <div class="font-mono text-[11.5px] text-muted-foreground">{{ item.product_code }} · ×{{ item.quantity }}</div>
                  </div>
                  <div class="text-right">
                    <div class="font-medium">{{ money(item.subtotal) }}</div>
                    <div class="text-[12px] text-muted-foreground">{{ money(item.unit_price) }} each</div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Totals -->
            <div class="flex flex-col gap-1 text-[13px] pt-1 border-t border-border/50">
              <div class="flex justify-between">
                <span class="text-muted-foreground">Subtotal</span>
                <span>{{ money(selectedOrder.subtotal) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-muted-foreground">Delivery fee</span>
                <span>{{ money(selectedOrder.delivery_fee) }}</span>
              </div>
              <div class="flex justify-between font-semibold text-[14px] pt-1 border-t border-border/50 mt-1">
                <span>Total</span>
                <span>{{ money(selectedOrder.total_amount) }}</span>
              </div>
            </div>

            <!-- Partial return button -->
            <div v-if="['DELIVERED','DELIVERING'].includes(selectedOrder.status)" class="pt-2 border-t border-border/50">
              <Button variant="outline" size="sm" @click="openPartialReturn">
                <RotateCcw :size="13" class="mr-1.5" />Partial Return
              </Button>
            </div>

            <!-- Status update -->
            <div v-if="!['DELIVERED','CANCELLED','RETURNED','PARTIALLY_RETURNED'].includes(selectedOrder.status)" class="pt-2 border-t border-border/50">
              <p class="text-[13px] font-semibold mb-3">Update status</p>
              <div class="flex flex-wrap gap-2">
                <Button
                  v-for="s in nextStatuses(selectedOrder.status)"
                  :key="s"
                  variant="outline"
                  size="sm"
                  :disabled="updatingStatus"
                  @click="changeStatus(selectedOrder, s)"
                >
                  <Loader2 v-if="updatingStatus && pendingStatus === s" :size="12" class="animate-spin" />
                  {{ statusLabel(s) }}
                </Button>
              </div>
              <!-- Return reason if RETURNED -->
              <div v-if="showReturnReason" class="mt-3 flex flex-col gap-2">
                <Label class="text-[13px]">Return reason <span class="text-red-500">*</span></Label>
                <select v-model="returnReason" class="h-9 w-full rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring">
                  <option value="CUSTOMER_CHANGE">Customer change</option>
                  <option value="STORE_ERROR">Store error</option>
                  <option value="CUSTOMER_RETURN">Customer return</option>
                </select>
                <Button size="sm" :disabled="updatingStatus" @click="confirmReturn">
                  <Loader2 v-if="updatingStatus" :size="12" class="animate-spin" />
                  Confirm return
                </Button>
              </div>
            </div>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <PrintInvoiceDialog :open="printOpen" :order="selectedOrder" @close="printOpen = false" />

    <!-- Partial Return Dialog -->
    <Dialog :open="partialReturnOpen" @update:open="(v) => !v && (partialReturnOpen = false)">
      <DialogContent class="max-w-lg p-0 gap-0 overflow-hidden">
        <DialogHeader class="px-6 pt-5 pb-4 border-b">
          <DialogTitle>Partial Return</DialogTitle>
        </DialogHeader>
        <div class="px-6 py-4 flex flex-col gap-4 max-h-[60vh] overflow-y-auto">
          <!-- Items -->
          <div>
            <p class="text-[13px] font-semibold mb-2">Select items to return</p>
            <div v-if="prLoading" class="flex flex-col gap-2">
              <div v-for="n in 2" :key="n" class="h-12 rounded-lg bg-muted animate-pulse" />
            </div>
            <div v-else class="flex flex-col gap-2">
              <div
                v-for="(item, i) in prItems"
                :key="i"
                class="flex items-center gap-3 px-3 py-2.5 rounded-lg border transition-colors"
                :class="item.checked ? 'border-primary/30 bg-primary/5' : 'border-border bg-muted/30'"
              >
                <input type="checkbox" v-model="item.checked" class="w-4 h-4 rounded accent-primary shrink-0" />
                <div class="flex-1 min-w-0">
                  <div class="text-[13px] font-medium leading-tight">{{ item.productName }}</div>
                  <div class="text-[11.5px] text-muted-foreground font-mono">{{ item.productCode }}</div>
                </div>
                <div v-if="item.checked" class="flex items-center gap-1 shrink-0">
                  <button
                    class="w-6 h-6 rounded border border-border bg-background flex items-center justify-center text-muted-foreground hover:text-foreground text-[13px]"
                    @click="item.returnQty = Math.max(1, item.returnQty - 1)"
                  >−</button>
                  <span class="w-6 text-center text-[13px] font-medium">{{ item.returnQty }}</span>
                  <button
                    class="w-6 h-6 rounded border border-border bg-background flex items-center justify-center text-muted-foreground hover:text-foreground text-[13px]"
                    @click="item.returnQty = Math.min(item.originalQty, item.returnQty + 1)"
                  >+</button>
                  <span class="text-[11.5px] text-muted-foreground ml-0.5">/ {{ item.originalQty }}</span>
                </div>
                <div v-else class="text-[12px] text-muted-foreground shrink-0">×{{ item.originalQty }}</div>
              </div>
            </div>
          </div>
          <!-- Return reason -->
          <div class="flex flex-col gap-1.5">
            <Label>Return reason <span class="text-red-500">*</span></Label>
            <select v-model="prReason" class="h-9 w-full rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring">
              <option value="CUSTOMER_CHANGE">Customer change</option>
              <option value="SIZE_CHANGE">Size change</option>
              <option value="CUSTOMER_RETURN">Customer return</option>
              <option value="STORE_ERROR">Store error</option>
            </select>
          </div>
          <!-- Note -->
          <div class="flex flex-col gap-1.5">
            <Label>Note <span class="text-muted-foreground font-normal text-[12px]">(optional)</span></Label>
            <Input v-model="prNote" placeholder="Optional note…" />
          </div>
          <!-- Error -->
          <div v-if="prError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
            <AlertTriangle :size="14" class="shrink-0" />{{ prError }}
          </div>
        </div>
        <div class="flex justify-end gap-2 px-6 py-4 border-t">
          <Button variant="outline" @click="partialReturnOpen = false">Cancel</Button>
          <Button :disabled="prSubmitting || prLoading" @click="submitPartialReturn">
            <Loader2 v-if="prSubmitting" :size="14" class="animate-spin" />
            {{ prSubmitting ? "Submitting…" : "Submit return" }}
          </Button>
        </div>
      </DialogContent>
    </Dialog>

    <!-- Create order drawer -->
    <Sheet :open="createOpen" @update:open="(v) => !v && (createOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[520px] sm:max-w-[520px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">New order</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="createOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">

            <!-- Customer search -->
            <div class="flex flex-col gap-1.5">
              <Label>Customer <span class="text-red-500">*</span></Label>
              <div class="relative">
                <Search :size="14" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
                <Input v-model="customerQuery" class="pl-8" placeholder="Search by name or phone…" @input="onCustomerSearch" />
              </div>
              <div v-if="customerResults.length" class="rounded-lg border border-border overflow-hidden">
                <button
                  v-for="c in customerResults"
                  :key="c.uuid"
                  class="w-full flex items-center gap-2.5 px-3 py-2.5 text-left text-[13px] hover:bg-muted transition-colors border-b border-border/50 last:border-0"
                  :class="selectedCustomer?.uuid === c.uuid ? 'bg-primary/5 font-medium' : ''"
                  @click="selectCustomer(c)"
                >
                  <UserAvatar :name="c.name" :size="26" />
                  <div class="flex-1 min-w-0">
                    <div class="font-medium">{{ c.name }}</div>
                    <div class="text-[11.5px] text-muted-foreground flex gap-2">
                      <span class="font-mono">{{ c.phone }}</span>
                      <span v-if="c.facebook_name">· FB: {{ c.facebook_name }}</span>
                    </div>
                  </div>
                </button>
              </div>
              <div v-else-if="customerQuery.trim() && !newCustomerOpen" class="rounded-lg border border-dashed border-border px-3 py-2.5 text-[13px] text-muted-foreground flex items-center justify-between">
                <span>No customer found</span>
                <button class="text-primary text-[12.5px] font-medium hover:underline" @click="openNewCustomer">+ Create new customer</button>
              </div>
              <!-- Inline quick-create form -->
              <div v-if="newCustomerOpen" class="rounded-lg border border-border bg-muted/30 p-3 flex flex-col gap-2.5">
                <p class="text-[12.5px] font-semibold">New customer</p>
                <Input v-model="newCust.name" placeholder="Name *" class="h-8 text-[13px]" />
                <Input v-model="newCust.phone" placeholder="Phone *" class="h-8 text-[13px]" />
                <Input v-model="newCust.facebook_name" placeholder="Facebook name (optional)" class="h-8 text-[13px]" />
                <p v-if="newCustError" class="text-[12px] text-red-500">{{ newCustError }}</p>
                <div class="flex gap-2">
                  <Button size="sm" class="flex-1 h-8 text-[12px]" :disabled="newCustSaving" @click="saveNewCustomer">
                    <Loader2 v-if="newCustSaving" :size="12" class="animate-spin" />
                    {{ newCustSaving ? "Saving…" : "Create & select" }}
                  </Button>
                  <Button size="sm" variant="outline" class="h-8 text-[12px]" @click="newCustomerOpen = false">Cancel</Button>
                </div>
              </div>
              <div v-if="selectedCustomer" class="flex items-center gap-2 rounded-lg border border-primary/20 bg-primary/5 px-3 py-2 text-[13px]">
                <UserAvatar :name="selectedCustomer.name" :size="24" />
                <span class="font-medium">{{ selectedCustomer.name }}</span>
                <span class="text-muted-foreground font-mono text-[12px]">{{ selectedCustomer.phone }}</span>
                <button class="ml-auto text-muted-foreground hover:text-foreground" @click="selectedCustomer = null; customerQuery = ''"><X :size="14" /></button>
              </div>
            </div>

            <!-- Items -->
            <div class="flex flex-col gap-2">
              <Label>Items <span class="text-red-500">*</span></Label>
              <div class="relative">
                <Search :size="14" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
                <Input v-model="productQuery" class="pl-8" placeholder="Search product by name or code…" @input="onProductSearch" />
              </div>
              <div v-if="productResults.length" class="rounded-lg border border-border overflow-hidden max-h-40 overflow-y-auto">
                <button
                  v-for="p in productResults"
                  :key="p.uuid"
                  class="w-full flex items-center justify-between px-3 py-2 text-left text-[13px] hover:bg-muted transition-colors border-b border-border/50 last:border-0"
                  @click="addItem(p)"
                >
                  <div>
                    <div class="font-medium">{{ p.name }}</div>
                    <div class="font-mono text-[11.5px] text-muted-foreground">{{ p.code }}</div>
                  </div>
                  <span class="text-muted-foreground text-[12px]">{{ p.current_stock }} in stock</span>
                </button>
              </div>
              <div v-if="orderItems.length" class="flex flex-col gap-1.5">
                <div v-for="(item, i) in orderItems" :key="item.productUuid"
                  class="flex items-center justify-between px-3 py-2 rounded-lg bg-muted/40 text-[13px]">
                  <span class="font-medium flex-1">{{ item.productName }}</span>
                  <div class="flex items-center gap-2">
                    <button class="w-6 h-6 rounded bg-background border border-border flex items-center justify-center text-muted-foreground hover:text-foreground" @click="item.quantity = Math.max(1, item.quantity - 1)">−</button>
                    <span class="w-6 text-center font-medium">{{ item.quantity }}</span>
                    <button class="w-6 h-6 rounded bg-background border border-border flex items-center justify-center text-muted-foreground hover:text-foreground" @click="item.quantity++">+</button>
                    <button class="ml-1 text-muted-foreground hover:text-destructive" @click="orderItems.splice(i, 1)"><X :size="13" /></button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Staff selector (ADMIN only) -->
            <div v-if="isAdmin" class="flex flex-col gap-1.5">
              <Label>Staff <span class="text-red-500">*</span></Label>
              <select v-model="selectedStaffUuid" class="h-9 rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring">
                <option value="" disabled>Select staff…</option>
                <option v-for="s in staffList" :key="s.uuid" :value="s.uuid">{{ s.name }}</option>
              </select>
            </div>

            <!-- Order options -->
            <div class="grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1.5">
                <Label>Page source <span class="text-red-500">*</span></Label>
                <select v-model="createForm.pageSource" class="h-9 rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring">
                  <option value="R99">R99</option>
                  <option value="R99_I">R99_I</option>
                </select>
              </div>
              <div class="flex flex-col gap-1.5">
                <Label>Payment type <span class="text-red-500">*</span></Label>
                <select v-model="createForm.paymentType" class="h-9 rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring">
                  <option value="PAY_ON_DELIVERY">Pay on delivery</option>
                  <option value="PAID_UPFRONT">Paid upfront</option>
                </select>
              </div>
            </div>
            <div v-if="createForm.paymentType === 'PAID_UPFRONT'" class="flex flex-col gap-1.5">
              <Label>Payment method <span class="text-red-500">*</span></Label>
              <select v-model="createForm.paymentMethod" class="h-9 rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring">
                <option value="CASH">Cash</option>
                <option value="BANK">Bank transfer</option>
              </select>
            </div>
            <label class="flex items-center gap-2 text-[13.5px] cursor-pointer select-none">
              <input type="checkbox" v-model="createForm.isPromotion" class="w-4 h-4 rounded border-border accent-primary" />
              Promotion order <span class="text-muted-foreground text-[12px]">(delivery fee waived)</span>
            </label>
            <div class="flex flex-col gap-1.5">
              <Label>Note</Label>
              <Input v-model="createForm.note" placeholder="Handle with care…" />
            </div>

            <div v-if="createError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ createError }}
            </div>
            <Button class="w-full mt-1" :disabled="creating" @click="submitOrder">
              <Loader2 v-if="creating" :size="14" class="animate-spin" />
              {{ creating ? "Creating…" : "Create order" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, h } from "vue";
import { Plus, X, Search, AlertTriangle, Loader2, Printer, RotateCcw } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import PrintInvoiceDialog from "@/components/admin/PrintInvoiceDialog.vue";
import UserAvatar from "@/components/admin/UserAvatar.vue";
import Pagination from "@/components/admin/Pagination.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useUIStore } from "@/stores/ui";
import { useSessionStore } from "@/stores/session";
import { fetchOrders, fetchOrder, createOrder, updateOrderStatus, partialReturnOrder } from "@/api/orders";
import { fetchUsers } from "@/api/users";
import type { UserResponse } from "@/api/users";
import type { OrderResponse, OrderStatus, ReturnReason, PartialReturnRequest } from "@/api/orders";
import { searchCustomers, createCustomer } from "@/api/customers";
import type { CustomerResponse } from "@/api/customers";
import { searchProducts } from "@/api/products";
import type { ProductSearchResult } from "@/api/products";
import type { PageMeta } from "@/api/users";
import { money, fmtDate } from "@/utils/format";

// ── Inline status badge ───────────────────────────────────────
const STATUS_STYLES: Record<string, string> = {
  PENDING:            "background:var(--amber-bg);color:var(--amber)",
  CONFIRMED:          "background:#dbeafe;color:#1d4ed8",
  DELIVERING:         "background:#ede9fe;color:#6d28d9",
  DELIVERED:          "background:var(--green-bg);color:var(--green)",
  CANCELLED:          "background:hsl(var(--muted));color:hsl(var(--muted-foreground))",
  RETURNED:           "background:var(--red-bg);color:var(--red)",
  PARTIALLY_RETURNED: "background:#fff7ed;color:#c2410c",
};
const OrderStatusBadge = {
  props: ["status"],
  setup(props: { status?: string }) {
    return () => {
      const s = (props.status ?? "").toUpperCase();
      return h("span", {
        class: "inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold",
        style: STATUS_STYLES[s] ?? "",
      }, [h("span", { class: "status-dot" }), s.replace(/_/g, " ")]);
    };
  },
};

const TABS = [
  { label: "All", value: "ALL" },
  { label: "Pending", value: "PENDING" },
  { label: "Confirmed", value: "CONFIRMED" },
  { label: "Delivering", value: "DELIVERING" },
  { label: "Delivered", value: "DELIVERED" },
  { label: "Cancelled", value: "CANCELLED" },
  { label: "Returned", value: "RETURNED" },
];

const ui = useUIStore();
const session = useSessionStore();
const isAdmin = (session.user?.role ?? '').toUpperCase() !== 'STAFF';

const staffList = ref<UserResponse[]>([]);
const selectedStaffUuid = ref("");

async function loadStaff() {
  try {
    const res = await fetchUsers(1, 100);
    staffList.value = res.users.filter((u) => (u.role ?? '').toUpperCase() !== 'ADMIN');
  } catch { /* silent */ }
}

const orders = ref<OrderResponse[]>([]);
const meta = ref<PageMeta | null>(null);
const loading = ref(false);
const loadError = ref("");
const currentPage = ref(1);
const activeTab = ref("ALL");

async function load(page = 1) {
  loading.value = true;
  loadError.value = "";
  try {
    const status = activeTab.value === "ALL" ? undefined : activeTab.value as OrderStatus;
    const res = await fetchOrders(page, 20, status);
    orders.value = res.orders;
    meta.value = res.meta;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load orders.";
  } finally {
    loading.value = false;
  }
}

function onTabChange() { currentPage.value = 1; load(1); }
function changePage(page: number) { currentPage.value = page; load(page); }
onMounted(() => load(1));

// ── Detail sheet ──────────────────────────────────────────────
const selectedOrder = ref<OrderResponse | null>(null);
const printOpen = ref(false);
const updatingStatus = ref(false);
const pendingStatus = ref<OrderStatus | null>(null);
const showReturnReason = ref(false);
const returnReason = ref<ReturnReason>("CUSTOMER_CHANGE");

function openDetail(o: OrderResponse) {
  selectedOrder.value = o;
  showReturnReason.value = false;
}

function nextStatuses(current: OrderStatus): OrderStatus[] {
  const map: Record<OrderStatus, OrderStatus[]> = {
    PENDING:            ["CONFIRMED", "CANCELLED"],
    CONFIRMED:          ["DELIVERING", "CANCELLED"],
    DELIVERING:         ["DELIVERED", "RETURNED"],
    DELIVERED:          [],
    CANCELLED:          [],
    RETURNED:           [],
    PARTIALLY_RETURNED: [],
  };
  return map[current] ?? [];
}

async function changeStatus(o: OrderResponse, status: OrderStatus) {
  if (status === "RETURNED") { showReturnReason.value = true; pendingStatus.value = status; return; }
  updatingStatus.value = true;
  pendingStatus.value = status;
  try {
    const updated = await updateOrderStatus(o.uuid, { status });
    selectedOrder.value = updated;
    const idx = orders.value.findIndex((x) => x.uuid === o.uuid);
    if (idx !== -1) orders.value[idx] = updated;
    ui.showToast(`Order ${status.toLowerCase()}`, "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to update status.", "danger");
  } finally {
    updatingStatus.value = false;
    pendingStatus.value = null;
  }
}

async function confirmReturn() {
  if (!selectedOrder.value) return;
  updatingStatus.value = true;
  try {
    const updated = await updateOrderStatus(selectedOrder.value.uuid, { status: "RETURNED", return_reason: returnReason.value });
    selectedOrder.value = updated;
    const idx = orders.value.findIndex((x) => x.uuid === updated.uuid);
    if (idx !== -1) orders.value[idx] = updated;
    showReturnReason.value = false;
    ui.showToast("Order marked as returned", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to update status.", "danger");
  } finally {
    updatingStatus.value = false;
  }
}

// ── Create order ──────────────────────────────────────────────
const createOpen = ref(false);
const creating = ref(false);
const createError = ref("");

const createForm = reactive({
  pageSource: "R99" as "R99" | "R99_I",
  paymentType: "PAY_ON_DELIVERY" as "PAID_UPFRONT" | "PAY_ON_DELIVERY",
  paymentMethod: "CASH" as "BANK" | "CASH",
  isPromotion: false,
  note: "",
});

const selectedCustomer = ref<CustomerResponse | null>(null);
const customerQuery = ref("");
const customerResults = ref<CustomerResponse[]>([]);
let customerTimer: ReturnType<typeof setTimeout> | null = null;

function onCustomerSearch() {
  if (customerTimer) clearTimeout(customerTimer);
  const q = customerQuery.value.trim();
  if (!q) { customerResults.value = []; return; }
  customerTimer = setTimeout(async () => {
    try { customerResults.value = await searchCustomers(q); } catch { /* silent */ }
  }, 300);
}

function selectCustomer(c: CustomerResponse) {
  selectedCustomer.value = c;
  customerResults.value = [];
  customerQuery.value = "";
  newCustomerOpen.value = false;
}

const newCustomerOpen = ref(false);
const newCust = reactive({ name: "", phone: "", facebook_name: "" });
const newCustError = ref("");
const newCustSaving = ref(false);

function openNewCustomer() {
  newCust.name = customerQuery.value.trim();
  newCust.phone = "";
  newCust.facebook_name = "";
  newCustError.value = "";
  newCustomerOpen.value = true;
}

async function saveNewCustomer() {
  if (!newCust.name.trim()) { newCustError.value = "Name is required."; return; }
  if (!newCust.phone.trim()) { newCustError.value = "Phone is required."; return; }
  newCustSaving.value = true;
  newCustError.value = "";
  try {
    const created = await createCustomer({
      name: newCust.name.trim(),
      phone: newCust.phone.trim(),
      facebook_name: newCust.facebook_name.trim() || undefined,
    });
    selectCustomer(created);
  } catch (e: unknown) {
    newCustError.value = e instanceof Error ? e.message : "Failed to create customer.";
  } finally {
    newCustSaving.value = false;
  }
}

interface OrderItemDraft { productUuid: string; productName: string; quantity: number }
const orderItems = ref<OrderItemDraft[]>([]);
const productQuery = ref("");
const productResults = ref<ProductSearchResult[]>([]);
let productTimer: ReturnType<typeof setTimeout> | null = null;

function onProductSearch() {
  if (productTimer) clearTimeout(productTimer);
  const q = productQuery.value.trim();
  if (!q) { productResults.value = []; return; }
  productTimer = setTimeout(async () => {
    try { productResults.value = await searchProducts(q); } catch { /* silent */ }
  }, 300);
}

function addItem(p: ProductSearchResult) {
  const existing = orderItems.value.find((i) => i.productUuid === p.uuid);
  if (existing) { existing.quantity++; }
  else { orderItems.value.push({ productUuid: p.uuid, productName: p.name, quantity: 1 }); }
  productQuery.value = "";
  productResults.value = [];
}

function openCreate() {
  selectedCustomer.value = null;
  customerQuery.value = "";
  customerResults.value = [];
  newCustomerOpen.value = false;
  orderItems.value = [];
  productQuery.value = "";
  productResults.value = [];
  createForm.pageSource = "R99";
  createForm.paymentType = "PAY_ON_DELIVERY";
  createForm.paymentMethod = "CASH";
  createForm.isPromotion = false;
  createForm.note = "";
  selectedStaffUuid.value = "";
  createError.value = "";
  createOpen.value = true;
  if (isAdmin && staffList.value.length === 0) loadStaff();
}

async function submitOrder() {
  if (!selectedCustomer.value) { createError.value = "Please select a customer."; return; }
  if (orderItems.value.length === 0) { createError.value = "Please add at least one item."; return; }
  creating.value = true;
  createError.value = "";
  try {
    if (isAdmin && !selectedStaffUuid.value) { createError.value = "Please select a staff member."; creating.value = false; return; }
    await createOrder({
      customer_uuid: selectedCustomer.value.uuid,
      staff_uuid: isAdmin ? selectedStaffUuid.value : undefined,
      page_source: createForm.pageSource,
      payment_type: createForm.paymentType,
      payment_method: createForm.paymentType === "PAID_UPFRONT" ? createForm.paymentMethod : undefined,
      is_promotion: createForm.isPromotion,
      note: createForm.note || undefined,
      items: orderItems.value.map((i) => ({ product_uuid: i.productUuid, quantity: i.quantity })),
    });
    createOpen.value = false;
    ui.showToast("Order created", "success");
    await load(1);
  } catch (e: unknown) {
    createError.value = e instanceof Error ? e.message : "Failed to create order.";
  } finally {
    creating.value = false;
  }
}

// ── Partial return ────────────────────────────────────────────
interface PRItem {
  checked: boolean;
  returnQty: number;
  originalQty: number;
  productUuid: string;
  productName: string;
  productCode: string;
}

const partialReturnOpen = ref(false);
const prSubmitting = ref(false);
const prError = ref("");
const prReason = ref<ReturnReason>("CUSTOMER_CHANGE");
const prNote = ref("");
const prItems = ref<PRItem[]>([]);

const prLoading = ref(false);

async function openPartialReturn() {
  if (!selectedOrder.value) return;
  prReason.value = "CUSTOMER_CHANGE";
  prNote.value = "";
  prError.value = "";
  prItems.value = [];
  prLoading.value = true;
  partialReturnOpen.value = true;
  try {
    const full = await fetchOrder(selectedOrder.value.uuid);
    // product_uuid is not returned on order items — resolve via product search by code
    prItems.value = await Promise.all(
      full.items.map(async (item) => {
        let productUuid = item.product_uuid ?? "";
        if (!productUuid) {
          try {
            const results = await searchProducts(item.product_code);
            productUuid = results.find((r) => r.code === item.product_code)?.uuid
              ?? results[0]?.uuid
              ?? "";
          } catch { /* silent — uuid stays empty, validation will catch it */ }
        }
        return {
          checked: false,
          returnQty: item.quantity,
          originalQty: item.quantity,
          productUuid,
          productName: item.product_name,
          productCode: item.product_code,
        };
      })
    );
  } catch {
    prError.value = "Failed to load order items.";
  } finally {
    prLoading.value = false;
  }
}

async function submitPartialReturn() {
  const selected = prItems.value.filter((i) => i.checked);
  if (selected.length === 0) { prError.value = "Please select at least one item to return."; return; }
  for (const item of selected) {
    if (!item.productUuid) {
      prError.value = `Could not resolve product UUID for "${item.productName}". Please try closing and reopening the dialog.`;
      return;
    }
    if (item.returnQty < 1 || item.returnQty > item.originalQty) {
      prError.value = `"${item.productName}" return quantity must be between 1 and ${item.originalQty}.`;
      return;
    }
  }
  if (!selectedOrder.value) return;
  prSubmitting.value = true;
  prError.value = "";
  try {
    const updated = await partialReturnOrder(selectedOrder.value.uuid, {
      return_reason: prReason.value,
      note: prNote.value.trim() || undefined,
      items: selected.map((i) => ({ product_uuid: i.productUuid, quantity: i.returnQty })),
    });
    selectedOrder.value = updated;
    const idx = orders.value.findIndex((x) => x.uuid === updated.uuid);
    if (idx !== -1) orders.value[idx] = updated;
    partialReturnOpen.value = false;
    ui.showToast("Partial return submitted", "success");
  } catch (e: unknown) {
    prError.value = e instanceof Error ? e.message : "Failed to submit partial return.";
  } finally {
    prSubmitting.value = false;
  }
}

function statusLabel(s: OrderStatus) { return s.replace(/_/g, " "); }
function paymentLabel(t: string) {
  return t === "PAID_UPFRONT" ? "Paid upfront" : "Pay on delivery";
}
</script>
