<template>
  <Dialog :open="open" @update:open="(v) => !v && emit('cancel')">
    <DialogContent class="max-w-sm">
      <DialogHeader>
        <DialogTitle>{{ title }}</DialogTitle>
        <DialogDescription>{{ description }}</DialogDescription>
      </DialogHeader>
      <DialogFooter class="gap-2 mt-2">
        <Button variant="outline" :disabled="loading" @click="emit('cancel')">
          {{ cancelLabel }}
        </Button>
        <Button :variant="confirmVariant" :disabled="loading" @click="emit('confirm')">
          <Loader2 v-if="loading" :size="14" class="animate-spin" />
          {{ loading ? loadingLabel : confirmLabel }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { Loader2 } from "@lucide/vue";
import { Button } from "@/components/ui/button";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter,
} from "@/components/ui/dialog";

withDefaults(defineProps<{
  open: boolean;
  title: string;
  description: string;
  confirmLabel?: string;
  cancelLabel?: string;
  loadingLabel?: string;
  confirmVariant?: "default" | "destructive" | "outline" | "ghost";
  loading?: boolean;
}>(), {
  confirmLabel: "Confirm",
  cancelLabel: "Cancel",
  loadingLabel: "Loading…",
  confirmVariant: "destructive",
  loading: false,
});

const emit = defineEmits<{
  confirm: [];
  cancel: [];
}>();
</script>
