import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import localizedFormat from 'dayjs/plugin/localizedFormat'

dayjs.extend(relativeTime)
dayjs.extend(localizedFormat)

export function money(n: number): string {
  return '$' + n.toLocaleString('en-US')
}

export function fmtDate(d: Date | string): string {
  return dayjs(d).format('MMM D, h:mm A')
}

export function fmtDateShort(d: Date | string): string {
  return dayjs(d).format('MMM D, YYYY')
}

export function timeAgo(d: Date | string): string {
  return dayjs(d).fromNow()
}

export function initials(name: string): string {
  return name.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase()
}
