// 맑은프레임워크 공통 JavaScript

// 페이지 로드 시 실행
document.addEventListener('DOMContentLoaded', function() {
    // 현재 페이지 네비게이션 활성화
    highlightCurrentNav();

    // 테이블 행 클릭 이벤트
    initTableRowClick();

    // 폼 제출 시 이중 클릭 방지
    preventDoubleSubmit();
});

// 현재 페이지 네비게이션 하이라이트
function highlightCurrentNav() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.navbar-nav .nav-link');

    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href && currentPath.includes(href) && href !== '/') {
            link.classList.add('active');
        }
        if (href === '/' && currentPath === '/') {
            link.classList.add('active');
        }
    });
}

// 테이블 행 클릭 시 상세 페이지로 이동
function initTableRowClick() {
    const tableRows = document.querySelectorAll('.table tbody tr');

    tableRows.forEach(row => {
        row.addEventListener('click', function(e) {
            // 링크를 직접 클릭한 경우는 제외
            if (e.target.tagName === 'A') {
                return;
            }

            const link = this.querySelector('a');
            if (link) {
                window.location.href = link.getAttribute('href');
            }
        });
    });
}

// 폼 이중 제출 방지
function preventDoubleSubmit() {
    const forms = document.querySelectorAll('form');

    forms.forEach(form => {
        form.addEventListener('submit', function() {
            const submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>처리 중...';

                // 5초 후 다시 활성화 (실패 시를 대비)
                setTimeout(() => {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = submitBtn.getAttribute('data-original-text') || '제출';
                }, 5000);
            }
        });
    });
}

// 유틸리티 함수들

// 날짜 포맷팅
function formatDate(dateStr) {
    if (!dateStr || dateStr.length < 8) return dateStr;

    const year = dateStr.substring(0, 4);
    const month = dateStr.substring(4, 6);
    const day = dateStr.substring(6, 8);

    if (dateStr.length >= 14) {
        const hour = dateStr.substring(8, 10);
        const minute = dateStr.substring(10, 12);
        return `${year}-${month}-${day} ${hour}:${minute}`;
    }

    return `${year}-${month}-${day}`;
}

// 숫자 포맷팅 (천단위 콤마)
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// 쿠키 설정
function setCookie(name, value, days) {
    let expires = "";
    if (days) {
        const date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + (value || "") + expires + "; path=/";
}

// 쿠키 가져오기
function getCookie(name) {
    const nameEQ = name + "=";
    const ca = document.cookie.split(';');
    for (let i = 0; i < ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) === ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}

// 쿠키 삭제
function deleteCookie(name) {
    document.cookie = name + '=; Max-Age=-99999999;';
}
