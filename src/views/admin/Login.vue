<template>
  <div class="flex min-h-screen bg-muted/30">
    <!-- Left branding panel -->
    <div
      class="login-brand hidden md:flex flex-col justify-between flex-[0_0_420px] bg-primary text-primary-foreground p-12 relative overflow-hidden"
    >
      <div
        class="absolute inset-0 opacity-[0.06]"
        style="
          background-image:
            linear-gradient(hsl(0 0% 100%) 1px, transparent 1px),
            linear-gradient(90deg, hsl(0 0% 100%) 1px, transparent 1px);
          background-size: 32px 32px;
        "
      />
      <div class="relative">
        <div class="flex items-center gap-3 mb-12">
          <div
            class="w-[38px] h-[38px] rounded-[10px] bg-white/15 grid place-items-center font-extrabold text-[18px] tracking-tight"
          >
            R
          </div>
          <span class="font-bold text-[18px] tracking-tight">R99 Studio</span>
        </div>
        <h2 class="text-[32px] font-bold leading-[1.15] tracking-tight mb-4">
          Admin &<br />Commerce Hub
        </h2>
        <p class="text-[14.5px] opacity-65 leading-relaxed max-w-[300px]">
          Manage your catalogue, orders, stock, models, and payroll — all in one
          place.
        </p>
      </div>
      <div class="relative text-[12.5px] opacity-45">
        R99 Studio · Admin v1.0 · {{ new Date().getFullYear() }}
      </div>
    </div>

    <!-- Right form panel -->
    <div class="flex flex-1 items-center justify-center p-6">
      <div class="w-full max-w-[420px]">
        <div class="mb-8">
          <h1 class="text-2xl font-bold tracking-tight">Sign in</h1>
          <p class="text-sm text-muted-foreground mt-1.5">
            Enter your credentials to access the admin.
          </p>
        </div>

        <form @submit="onSubmit" class="flex flex-col gap-4">
          <FormField v-slot="{ componentField }" name="email">
            <FormItem>
              <FormLabel>Email address</FormLabel>
              <FormControl>
                <Input
                  v-bind="componentField"
                  type="email"
                  placeholder="you@r99.studio"
                  autocomplete="email"
                  autofocus
                  class="h-10"
                  @input="serverError = ''"
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>

          <FormField v-slot="{ componentField }" name="password">
            <FormItem>
              <FormLabel>Password</FormLabel>
              <FormControl>
                <div class="relative">
                  <Input
                    v-bind="componentField"
                    :type="showPw ? 'text' : 'password'"
                    placeholder="••••••••"
                    autocomplete="current-password"
                    class="h-10 pr-12"
                    @input="serverError = ''"
                  />
                  <button
                    type="button"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-[12px] font-medium text-muted-foreground hover:text-foreground transition-colors"
                    @click="showPw = !showPw"
                  >
                    {{ showPw ? "Hide" : "Show" }}
                  </button>
                </div>
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>

          <div
            v-if="serverError"
            class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600"
          >
            <AlertTriangle :size="14" class="shrink-0" />{{ serverError }}
          </div>

          <div class="flex items-center gap-2.5">
            <button
              type="button"
              class="w-[18px] h-[18px] rounded-[5px] border-[1.5px] grid place-items-center shrink-0 transition-all"
              :class="
                remember
                  ? 'border-primary bg-primary text-primary-foreground'
                  : 'border-border bg-card'
              "
              @click="remember = !remember"
            >
              <Check v-if="remember" :size="11" />
            </button>
            <span class="text-[13.5px] text-muted-foreground"
              >Remember me for 30 days</span
            >
          </div>

          <Button
            type="submit"
            class="h-11 text-[15px] mt-1 w-full"
            :disabled="loading"
          >
            {{ loading ? "Signing in…" : "Sign in →" }}
          </Button>
        </form>

        <!-- Demo credentials -->
        <div class="mt-7 rounded-xl border bg-card p-4 text-[12.5px]">
          <div
            class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground mb-2"
          >
            Demo credentials
          </div>
          <div class="flex flex-col gap-1.5">
            <button
              v-for="u in DEMO_USERS"
              :key="u.email"
              type="button"
              class="flex justify-between items-center px-2.5 py-1.5 rounded-[7px] border border-border bg-muted hover:bg-muted/80 transition-colors cursor-pointer text-left font-inherit"
              @click="fillDemo(u)"
            >
              <div>
                <span class="font-medium text-[13px]">{{ u.email }}</span>
                <span class="text-muted-foreground ml-2 text-[11.5px]"
                  >/ {{ u.password }}</span
                >
              </div>
              <span
                class="inline-flex items-center rounded-md bg-secondary text-secondary-foreground px-2 py-0.5 text-[11px] font-semibold"
                >{{ u.role }}</span
              >
            </button>
          </div>
          <p class="text-muted-foreground text-[11.5px] mt-2">
            Click a row to auto-fill credentials.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { toTypedSchema } from "@vee-validate/zod";
import { useForm } from "vee-validate";
import { z } from "zod";
import { AlertTriangle, Check } from "@lucide/vue";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from "@/components/ui/form";
import { useSessionStore } from "@/stores/session";
import type { SessionUser } from "@/stores/session";

const router = useRouter();
const session = useSessionStore();

const remember = ref(false);
const serverError = ref("");
const loading = ref(false);
const showPw = ref(false);

const formSchema = toTypedSchema(
  z.object({
    email: z.string().email("Please enter a valid email address."),
    password: z.string().min(1, "Password is required."),
  }),
);

const DEMO_USERS = [
  { email: "admin@r99.studio", password: "admin123", role: "Owner" },
  { email: "staff@r99.studio", password: "staff123", role: "Staff" },
  { email: "viewer@r99.studio", password: "viewer123", role: "Viewer" },
  { email: "mia@r99.studio", password: "mia12345", role: "Manager" },
];

const USERS = [
  {
    email: "admin@r99.studio",
    password: "admin123",
    id: "u1",
    name: "Avery Quinn",
    role: "Owner" as const,
  },
  {
    email: "staff@r99.studio",
    password: "staff123",
    id: "u2",
    name: "Jordan Lee",
    role: "Staff" as const,
  },
  {
    email: "viewer@r99.studio",
    password: "viewer123",
    id: "u3",
    name: "Sam Rivera",
    role: "Viewer" as const,
  },
  {
    email: "mia@r99.studio",
    password: "mia12345",
    id: "u4",
    name: "Mia Thornton",
    role: "Manager" as const,
  },
  {
    email: "kai@r99.studio",
    password: "kai12345",
    id: "u5",
    name: "Kai Nakamura",
    role: "Staff" as const,
  },
];

const { handleSubmit, setValues } = useForm({ validationSchema: formSchema });

const onSubmit = handleSubmit((values) => {
  serverError.value = "";
  loading.value = true;
  setTimeout(() => {
    const found = USERS.find(
      (u) =>
        u.email.toLowerCase() === values.email.trim().toLowerCase() &&
        u.password === values.password,
    );
    if (found) {
      const user: SessionUser = {
        id: found.id,
        name: found.name,
        email: found.email,
        role: found.role,
        loginAt: Date.now(),
      };
      session.login(user, remember.value);
      router.push("/admin");
    } else {
      serverError.value = "Incorrect email or password. Please try again.";
      loading.value = false;
    }
  }, 600);
});

function fillDemo(u: { email: string; password: string }) {
  setValues({ email: u.email, password: u.password });
  serverError.value = "";
}
</script>
