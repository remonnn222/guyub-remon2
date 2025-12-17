import { useState, useCallback, useMemo } from 'react';
import { PaginationMeta, PaginationParams } from '@/types';

interface UsePaginationOptions {
  initialPage?: number;
  initialPerPage?: number;
  initialSortBy?: string;
  initialSortOrder?: 'asc' | 'desc';
}

export function usePagination(options: UsePaginationOptions = {}) {
  const {
    initialPage = 1,
    initialPerPage = 10,
    initialSortBy = 'created_at',
    initialSortOrder = 'desc',
  } = options;

  const [page, setPage] = useState(initialPage);
  const [perPage, setPerPage] = useState(initialPerPage);
  const [sortBy, setSortBy] = useState(initialSortBy);
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>(initialSortOrder);
  const [meta, setMeta] = useState<PaginationMeta | null>(null);

  const params: PaginationParams = useMemo(
    () => ({
      page,
      per_page: perPage,
      sort_by: sortBy,
      sort_order: sortOrder,
    }),
    [page, perPage, sortBy, sortOrder]
  );

  const goToPage = useCallback((newPage: number) => {
    setPage(newPage);
  }, []);

  const nextPage = useCallback(() => {
    if (meta && page < meta.total_pages) {
      setPage((prev) => prev + 1);
    }
  }, [meta, page]);

  const prevPage = useCallback(() => {
    if (page > 1) {
      setPage((prev) => prev - 1);
    }
  }, [page]);

  const changePerPage = useCallback((newPerPage: number) => {
    setPerPage(newPerPage);
    setPage(1); // Reset to first page when changing page size
  }, []);

  const changeSort = useCallback(
    (newSortBy: string) => {
      if (sortBy === newSortBy) {
        // Toggle sort order if clicking same column
        setSortOrder((prev) => (prev === 'asc' ? 'desc' : 'asc'));
      } else {
        setSortBy(newSortBy);
        setSortOrder('asc');
      }
      setPage(1); // Reset to first page when sorting
    },
    [sortBy]
  );

  const reset = useCallback(() => {
    setPage(initialPage);
    setPerPage(initialPerPage);
    setSortBy(initialSortBy);
    setSortOrder(initialSortOrder);
  }, [initialPage, initialPerPage, initialSortBy, initialSortOrder]);

  const updateMeta = useCallback((newMeta: PaginationMeta) => {
    setMeta(newMeta);
  }, []);

  const paginationInfo = useMemo(() => {
    if (!meta) return null;
    return {
      from: meta.from,
      to: meta.to,
      total: meta.total,
      currentPage: meta.current_page,
      totalPages: meta.total_pages,
      hasNextPage: page < meta.total_pages,
      hasPrevPage: page > 1,
    };
  }, [meta, page]);

  return {
    // State
    page,
    perPage,
    sortBy,
    sortOrder,
    meta,

    // Computed
    params,
    paginationInfo,

    // Actions
    goToPage,
    nextPage,
    prevPage,
    changePerPage,
    changeSort,
    reset,
    updateMeta,
  };
}

export default usePagination;
