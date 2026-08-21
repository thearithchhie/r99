<template>
  <AdminLayout>
    <DataNotFound
      v-if="store.error && !loading"
      :message="store.error"
      :back-to="ADMIN_ROUTES.users.list"
      back-label="Back to users"
    />

    <div v-else class="p-6 max-w-2xl mx-auto">
      <button
        class="flex items-center gap-1.5 text-[13px] text-muted-foreground hover:text-foreground transition-colors mb-4"
        @click="router.back()"
      >
        <ArrowLeft :size="14" /> Back to users
      </button>

      <h1 class="text-[20px] font-semibold mb-5">Edit User</h1>

      <!-- Loading skeleton -->
      <Card v-if="loading">
        <div class="flex items-center gap-3 px-8 py-5 border-b border-border/40">
          <div class="w-11 h-11 rounded-full bg-muted animate-pulse shrink-0" />
          <div class="flex flex-col gap-2">
            <div class="h-4 w-36 rounded bg-muted animate-pulse" />
            <div class="h-3 w-20 rounded bg-muted animate-pulse" />
          </div>
        </div>
        <div v-for="n in 2" :key="n" class="flex items-center px-8 py-5 gap-8 border-b border-border/40 last:border-0">
          <div class="h-4 w-24 rounded bg-muted animate-pulse shrink-0" />
          <div class="h-9 rounded bg-muted animate-pulse flex-1 max-w-xs" />
        </div>
      </Card>

      <Card v-else-if="store.selectedUser">
        <!-- Header -->
        <div class="flex items-center gap-3 px-8 py-5 border-b border-border/40">
          <UserAvatar :name="store.selectedUser.name" :size="44" />
          <div>
            <p class="text-[14px] font-semibold">{{ store.selectedUser.name }}</p>
            <span
              class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold mt-0.5"
              :style="store.selectedUser.status?.toUpperCase() === 'ACTIVE'
                ? 'background:var(--green-bg);color:var(--green)'
                : 'background:var(--red-bg);color:var(--red)'"
            ><span class="status-dot" />{{ store.selectedUser.status?.toUpperCase() }}</span>
          </div>
        </div>

        <!-- Name -->
        <div class="flex items-start px-8 py-5 border-b border-border/40">
          <span class="w-36 text-[13px] text-muted-foreground shrink-0 pt-2">Name</span>
          <div class="flex-1 flex flex-col gap-1">
            <Input v-model="name" :error="errors.name" class="max-w-xs h-9 text-[13.5px]" />
            <p v-if="errors.name" class="text-[12px] text-red-500">{{ errors.name }}</p>
          </div>
        </div>

        <!-- Phone -->
        <div class="flex items-start px-8 py-5 border-b border-border/40">
          <span class="w-36 text-[13px] text-muted-foreground shrink-0 pt-2">Phone</span>
          <div class="flex-1 flex flex-col gap-1">
            <Input v-model="phone" type="tel" :error="errors.phone" class="max-w-xs h-9 text-[13.5px]" />
            <p v-if="errors.phone" class="text-[12px] text-red-500">{{ errors.phone }}</p>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex items-center justify-end gap-2.5 px-8 py-4 border-t border-border/40">
          <Button variant="outline" :disabled="saving" @click="router.back()">Cancel</Button>
          <Button :disabled="saving" class="bg-blue-600 hover:bg-blue-700 text-white" @click="save">
            <Loader2 v-if="saving" :size="13" class="animate-spin mr-1" />
            Save
          </Button>
        </div>
      </Card>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { onMounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";
import { ArrowLeft, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import UserAvatar from "@/components/admin/UserAvatar.vue";
import DataNotFound from "@/components/admin/DataNotFound.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useUsersStore } from "@/stores/users";
import { useUIStore } from "@/stores/ui";
import { updateUser } from "@/api/users";
import { ADMIN_ROUTES } from "@/router/admin-routes";

const EditUserSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  phone: z.string().min(1, 'Phone is required'),
})

const route = useRoute();
const router = useRouter();
const store = useUsersStore();
const ui = useUIStore();

const loading = ref(true);
const saving = ref(false);

const { defineField, handleSubmit, errors, setValues } = useForm({
  validationSchema: toTypedSchema(EditUserSchema),
  initialValues: { name: '', phone: '' },
})

const [name] = defineField('name')
const [phone] = defineField('phone')

onMounted(async () => {
  loading.value = true;
  try {
    await store.loadUser(route.params.uuid as string);
    const u = store.selectedUser;
    if (u) setValues({ name: u.name, phone: u.phone });
  } finally {
    loading.value = false;
  }
});

const save = handleSubmit(async (values) => {
  saving.value = true;
  try {
    const uuid = route.params.uuid as string;
    await updateUser(uuid, { name: values.name, phone: values.phone });
    await store.loadUser(uuid);
    ui.showToast("User updated", "success");
    router.push(ADMIN_ROUTES.users.list);
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to update user", "danger");
  } finally {
    saving.value = false;
  }
});
</script>
