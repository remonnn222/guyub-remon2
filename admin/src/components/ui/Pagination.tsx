import { clsx } from 'clsx';
import {
  ChevronLeftIcon,
  ChevronRightIcon,
  ChevronDoubleLeftIcon,
  ChevronDoubleRightIcon,
} from '@heroicons/react/24/outline';

export interface PaginationProps {
  currentPage: number;
  totalPages: number;
  totalItems: number;
  from: number;
  to: number;
  onPageChange: (page: number) => void;
  perPage?: number;
  onPerPageChange?: (perPage: number) => void;
  perPageOptions?: number[];
}

const Pagination: React.FC<PaginationProps> = ({
  currentPage,
  totalPages,
  totalItems,
  from,
  to,
  onPageChange,
  perPage,
  onPerPageChange,
  perPageOptions = [10, 25, 50, 100],
}) => {
  const hasNextPage = currentPage < totalPages;
  const hasPrevPage = currentPage > 1;

  // Generate page numbers to display
  const getPageNumbers = (): (number | 'ellipsis')[] => {
    const pages: (number | 'ellipsis')[] = [];
    const showPages = 5; // Number of page buttons to show

    if (totalPages <= showPages + 2) {
      // Show all pages if total is small
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      // Always show first page
      pages.push(1);

      if (currentPage <= 3) {
        // Near the start
        for (let i = 2; i <= showPages; i++) {
          pages.push(i);
        }
        pages.push('ellipsis');
      } else if (currentPage >= totalPages - 2) {
        // Near the end
        pages.push('ellipsis');
        for (let i = totalPages - showPages + 1; i < totalPages; i++) {
          pages.push(i);
        }
      } else {
        // In the middle
        pages.push('ellipsis');
        for (let i = currentPage - 1; i <= currentPage + 1; i++) {
          pages.push(i);
        }
        pages.push('ellipsis');
      }

      // Always show last page
      pages.push(totalPages);
    }

    return pages;
  };

  const pageNumbers = getPageNumbers();

  return (
    <div className="flex flex-col sm:flex-row items-center justify-between gap-4 px-4 py-3 bg-white border-t border-gray-200 sm:px-6">
      {/* Info text */}
      <div className="text-sm text-gray-700">
        Showing <span className="font-medium">{from}</span> to{' '}
        <span className="font-medium">{to}</span> of{' '}
        <span className="font-medium">{totalItems}</span> results
      </div>

      {/* Per page selector */}
      {onPerPageChange && (
        <div className="flex items-center gap-2">
          <span className="text-sm text-gray-700">Show</span>
          <select
            value={perPage}
            onChange={(e) => onPerPageChange(Number(e.target.value))}
            className="px-2 py-1 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            {perPageOptions.map((option) => (
              <option key={option} value={option}>
                {option}
              </option>
            ))}
          </select>
          <span className="text-sm text-gray-700">per page</span>
        </div>
      )}

      {/* Pagination controls */}
      <nav className="flex items-center gap-1">
        {/* First page */}
        <button
          onClick={() => onPageChange(1)}
          disabled={!hasPrevPage}
          className={clsx(
            'p-2 rounded-md transition-colors',
            hasPrevPage
              ? 'text-gray-500 hover:bg-gray-100'
              : 'text-gray-300 cursor-not-allowed'
          )}
          title="First page"
        >
          <ChevronDoubleLeftIcon className="h-4 w-4" />
        </button>

        {/* Previous page */}
        <button
          onClick={() => onPageChange(currentPage - 1)}
          disabled={!hasPrevPage}
          className={clsx(
            'p-2 rounded-md transition-colors',
            hasPrevPage
              ? 'text-gray-500 hover:bg-gray-100'
              : 'text-gray-300 cursor-not-allowed'
          )}
          title="Previous page"
        >
          <ChevronLeftIcon className="h-4 w-4" />
        </button>

        {/* Page numbers */}
        <div className="hidden sm:flex items-center gap-1">
          {pageNumbers.map((page, index) =>
            page === 'ellipsis' ? (
              <span
                key={`ellipsis-${index}`}
                className="px-3 py-2 text-sm text-gray-500"
              >
                ...
              </span>
            ) : (
              <button
                key={page}
                onClick={() => onPageChange(page)}
                className={clsx(
                  'px-3 py-1 text-sm rounded-md transition-colors',
                  page === currentPage
                    ? 'bg-primary-600 text-white'
                    : 'text-gray-700 hover:bg-gray-100'
                )}
              >
                {page}
              </button>
            )
          )}
        </div>

        {/* Mobile page indicator */}
        <span className="sm:hidden px-3 py-1 text-sm text-gray-700">
          {currentPage} / {totalPages}
        </span>

        {/* Next page */}
        <button
          onClick={() => onPageChange(currentPage + 1)}
          disabled={!hasNextPage}
          className={clsx(
            'p-2 rounded-md transition-colors',
            hasNextPage
              ? 'text-gray-500 hover:bg-gray-100'
              : 'text-gray-300 cursor-not-allowed'
          )}
          title="Next page"
        >
          <ChevronRightIcon className="h-4 w-4" />
        </button>

        {/* Last page */}
        <button
          onClick={() => onPageChange(totalPages)}
          disabled={!hasNextPage}
          className={clsx(
            'p-2 rounded-md transition-colors',
            hasNextPage
              ? 'text-gray-500 hover:bg-gray-100'
              : 'text-gray-300 cursor-not-allowed'
          )}
          title="Last page"
        >
          <ChevronDoubleRightIcon className="h-4 w-4" />
        </button>
      </nav>
    </div>
  );
};

export default Pagination;
