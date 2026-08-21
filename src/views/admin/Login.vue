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
          <FormField v-slot="{ componentField }" name="phone">
            <FormItem>
              <FormLabel>Phone number</FormLabel>
              <FormControl>
                <Input
                  v-bind="componentField"
                  type="tel"
                  placeholder="+855 12 345 678"
                  autocomplete="tel"
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
            <span class="text-[13.5px] text-muted-foreground">Remember me for 30 days</span>
          </div>

          <Button
            type="submit"
            class="h-11 text-[15px] mt-1 w-full"
            :disabled="loading"
          >
            {{ loading ? "Signing in…" : "Sign in →" }}
          </Button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { toTypedSchema } from '@vee-validate/zod'
import { useForm } from 'vee-validate'
import { z } from 'zod'
import { AlertTriangle, Check } from '@lucide/vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  FormField, FormItem, FormLabel, FormControl, FormMessage,
} from '@/components/ui/form'
import { useSessionStore } from '@/stores/session'
import type { SessionUser } from '@/stores/session'
import { loginApi } from '@/api/auth'
import { ADMIN_ROUTES } from '@/router/admin-routes'

const router = useRouter()
const session = useSessionStore()

const remember = ref(false)
const serverError = ref('')
const loading = ref(false)
const showPw = ref(false)

const formSchema = toTypedSchema(
  z.object({
    phone: z.string().min(1, 'Phone number is required.'),
    password: z.string().min(1, 'Password is required.'),
  }),
)

const { handleSubmit } = useForm({ validationSchema: formSchema })

const onSubmit = handleSubmit(async (values) => {
  serverError.value = ''
  loading.value = true
  try {
    const authData = await loginApi({ phone: values.phone, password: values.password })

    const user: SessionUser = {
      uuid: authData.uuid,
      name: authData.name,
      phone: authData.phone,
      role: authData.role,
      loginAt: Date.now(),
      token: authData.token,
    }
    session.login(user, remember.value)
    router.push(ADMIN_ROUTES.dashboard)
  } catch (e: unknown) {
    serverError.value = e instanceof Error ? e.message : 'Incorrect phone or password.'
  } finally {
    loading.value = false
  }
})
</script>