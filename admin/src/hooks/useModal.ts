import { useCallback } from 'react';
import { useUIStore } from '@/stores/uiStore';

export function useModal(modalId: string) {
  const { activeModal, modalData, openModal, closeModal } = useUIStore();

  const isOpen = activeModal === modalId;

  const open = useCallback(
    (data?: Record<string, unknown>) => {
      openModal(modalId, data);
    },
    [modalId, openModal]
  );

  const close = useCallback(() => {
    closeModal();
  }, [closeModal]);

  return {
    isOpen,
    data: isOpen ? modalData : null,
    open,
    close,
  };
}

export default useModal;
