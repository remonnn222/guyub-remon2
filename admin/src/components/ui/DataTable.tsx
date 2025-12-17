import { clsx } from 'clsx';
import {
  ChevronUpIcon,
  ChevronDownIcon,
  ChevronUpDownIcon,
} from '@heroicons/react/24/outline';
import { TableColumn } from '@/types';

export interface DataTableProps<T> {
  columns: TableColumn<T>[];
  data: T[];
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  onSort?: (key: string) => void;
  isLoading?: boolean;
  emptyMessage?: string;
  rowKey: keyof T | ((item: T) => string | number);
  onRowClick?: (item: T) => void;
  selectedRows?: (string | number)[];
  onSelectRow?: (id: string | number) => void;
  onSelectAll?: (selected: boolean) => void;
}

function DataTable<T>({
  columns,
  data,
  sortBy,
  sortOrder,
  onSort,
  isLoading = false,
  emptyMessage = 'No data available',
  rowKey,
  onRowClick,
  selectedRows,
  onSelectRow,
  onSelectAll,
}: DataTableProps<T>) {
  const getRowKey = (item: T): string | number => {
    if (typeof rowKey === 'function') {
      return rowKey(item);
    }
    return item[rowKey] as string | number;
  };

  const getCellValue = (item: T, column: TableColumn<T>) => {
    if (column.render) {
      return column.render(item);
    }

    const keys = (column.key as string).split('.');
    let value: unknown = item;
    for (const key of keys) {
      value = (value as Record<string, unknown>)?.[key];
    }
    return value as React.ReactNode;
  };

  const renderSortIcon = (columnKey: string) => {
    if (!sortBy || sortBy !== columnKey) {
      return <ChevronUpDownIcon className="h-4 w-4 text-gray-400" />;
    }
    return sortOrder === 'asc' ? (
      <ChevronUpIcon className="h-4 w-4 text-primary-600" />
    ) : (
      <ChevronDownIcon className="h-4 w-4 text-primary-600" />
    );
  };

  const allSelected =
    selectedRows && data.length > 0 && selectedRows.length === data.length;
  const someSelected =
    selectedRows && selectedRows.length > 0 && selectedRows.length < data.length;

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="spinner h-8 w-8 text-primary-600" />
      </div>
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="table">
        <thead>
          <tr>
            {onSelectRow && (
              <th className="w-10">
                <input
                  type="checkbox"
                  className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                  checked={allSelected}
                  ref={(el) => {
                    if (el) {
                      el.indeterminate = someSelected || false;
                    }
                  }}
                  onChange={(e) => onSelectAll?.(e.target.checked)}
                />
              </th>
            )}
            {columns.map((column) => (
              <th
                key={column.key as string}
                className={clsx(
                  column.sortable && 'cursor-pointer select-none',
                  column.className
                )}
                onClick={() =>
                  column.sortable && onSort?.(column.key as string)
                }
              >
                <div className="flex items-center gap-1">
                  {column.label}
                  {column.sortable && renderSortIcon(column.key as string)}
                </div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200 bg-white">
          {data.length === 0 ? (
            <tr>
              <td
                colSpan={columns.length + (onSelectRow ? 1 : 0)}
                className="px-6 py-12 text-center text-gray-500"
              >
                {emptyMessage}
              </td>
            </tr>
          ) : (
            data.map((item) => {
              const key = getRowKey(item);
              const isSelected = selectedRows?.includes(key);

              return (
                <tr
                  key={key}
                  className={clsx(
                    onRowClick && 'cursor-pointer',
                    isSelected && 'bg-primary-50'
                  )}
                  onClick={() => onRowClick?.(item)}
                >
                  {onSelectRow && (
                    <td className="w-10" onClick={(e) => e.stopPropagation()}>
                      <input
                        type="checkbox"
                        className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                        checked={isSelected}
                        onChange={() => onSelectRow(key)}
                      />
                    </td>
                  )}
                  {columns.map((column) => (
                    <td
                      key={`${key}-${column.key as string}`}
                      className={column.className}
                    >
                      {getCellValue(item, column)}
                    </td>
                  ))}
                </tr>
              );
            })
          )}
        </tbody>
      </table>
    </div>
  );
}

export default DataTable;
