<script lang="ts">
    import { Button } from './index.js';

    const {
        onFormat,
        onClear,
        onToggleTheme,
        onToggleMinimap,
        language = 'javascript',
        theme = 'vs',
        showMinimap = false,
        ...rest
    }: {
        onFormat?: () => void;
        onClear?: () => void;
        onToggleTheme?: () => void;
        onToggleMinimap?: () => void;
        language?: string;
        theme?: string;
        showMinimap?: boolean;
        [key: string]: any;
    } = $props();

    // 语言显示名称映射
    const getLanguageDisplayName = (lang: string) => {
        switch (lang) {
            case 'javascript':
            case 'js':
                return 'JavaScript';
            case 'python':
                return 'Python';
            case 'qlexpress':
                return 'QLExpress';
            default:
                return lang.toUpperCase();
        }
    };

    // 主题显示名称映射
    const getThemeDisplayName = (themeValue: string) => {
        switch (themeValue) {
            case 'vs':
                return '浅色';
            case 'vs-dark':
                return '深色';
            case 'hc-black':
                return '高对比度';
            default:
                return themeValue;
        }
    };
</script>

<div class="code-editor-toolbar" {...rest}>
    <div class="toolbar-left">
        <span class="language-indicator">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M23 12L15.9289 19.0711L14.5147 17.6569L20.1716 12L14.5147 6.34317L15.9289 4.92896L23 12ZM3.82843 12L9.48528 17.6569L8.07107 19.0711L1 12L8.07107 4.92896L9.48528 6.34317L3.82843 12Z"/>
            </svg>
            {getLanguageDisplayName(language)}
        </span>
        
        <span class="theme-indicator">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 18C8.68629 18 6 15.3137 6 12C6 8.68629 8.68629 6 12 6C15.3137 6 18 8.68629 18 12C18 15.3137 15.3137 18 12 18ZM12 16C14.2091 16 16 14.2091 16 12C16 9.79086 14.2091 8 12 8C9.79086 8 8 9.79086 8 12C8 14.2091 9.79086 16 12 16ZM11 1H13V4H11V1ZM11 20H13V23H11V20ZM3.51472 4.92893L4.92893 3.51472L7.05025 5.63604L5.63604 7.05025L3.51472 4.92893ZM16.9497 18.364L18.364 16.9497L20.4853 19.0711L19.0711 20.4853L16.9497 18.364ZM19.0711 3.51472L20.4853 4.92893L18.364 7.05025L16.9497 5.63604L19.0711 3.51472ZM5.63604 16.9497L7.05025 18.364L4.92893 20.4853L3.51472 19.0711L5.63604 16.9497ZM23 11V13H20V11H23ZM4 11V13H1V11H4Z"/>
            </svg>
            {getThemeDisplayName(theme)}
        </span>
    </div>
    
    <div class="toolbar-right">
        {#if onFormat}
            <Button 
                onclick={onFormat}
                title="格式化代码 (Shift+Alt+F)"
                class="toolbar-btn"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M8 3V5H4V9H2V3H8ZM2 21V15H4V19H8V21H2ZM22 21H16V19H20V15H22V21ZM22 9H20V5H16V3H22V9ZM6 7V11H18V7H6ZM6 13V17H14V13H6Z"/>
                </svg>
                格式化
            </Button>
        {/if}
        
        {#if onToggleTheme}
            <Button 
                onclick={onToggleTheme}
                title="切换主题"
                class="toolbar-btn"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M10 7C10 10.866 13.134 14 17 14C18.9584 14 20.729 13.1957 21.9995 11.8995C22 11.933 22 11.9665 22 12C22 17.5228 17.5228 22 12 22C6.47715 22 2 17.5228 2 12C2 6.47715 6.47715 2 12 2C12.0335 2 12.067 2 12.1005 2.00049C10.8043 3.27098 10 5.04157 10 7ZM4 12C4 16.4183 7.58172 20 12 20C15.0583 20 17.7158 18.2839 19.062 15.7621C18.3945 15.9187 17.7035 16 17 16C12.0294 16 8 11.9706 8 7C8 6.29648 8.08133 5.60547 8.2379 4.938C5.71611 6.28423 4 8.9417 4 12Z"/>
                </svg>
                主题
            </Button>
        {/if}
        
        {#if onToggleMinimap}
            <Button
                onclick={onToggleMinimap}
                title="切换小地图"
                class="toolbar-btn {showMinimap ? 'active' : ''}"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M18 3V5H16V3H18ZM16 7V9H18V7H16ZM18 11V13H16V11H18ZM16 15V17H18V15H16ZM18 19V21H16V19H18ZM2 3H14V21H2V3ZM4 5V19H12V5H4ZM20 3H22V21H20V3Z"/>
                </svg>
                小地图
            </Button>
        {/if}
        
        {#if onClear}
            <Button 
                onclick={onClear}
                title="清空代码"
                class="toolbar-btn toolbar-btn-danger"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M7 4V2C7 1.44772 7.44772 1 8 1H16C16.5523 1 17 1.44772 17 2V4H20C20.5523 4 21 4.44772 21 5C21 5.55228 20.5523 6 20 6H19V21C19 21.5523 18.5523 22 18 22H6C5.44772 22 5 21.5523 5 21V6H4C3.44772 6 3 5.55228 3 5C3 4.44772 3.44772 4 4 4H7ZM9 3V4H15V3H9ZM7 6V20H17V6H7ZM9 8H11V18H9V8ZM13 8H15V18H13V8Z"/>
                </svg>
                清空
            </Button>
        {/if}
    </div>
</div>

<style lang="less">
    .code-editor-toolbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 6px 8px;
        background: #f8f9fa;
        border: 1px solid #ccc;
        border-bottom: none;
        border-radius: 5px 5px 0 0;
        font-size: 12px;
        min-height: 32px;
    }

    .toolbar-left {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .toolbar-right {
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .language-indicator,
    .theme-indicator {
        display: flex;
        align-items: center;
        gap: 4px;
        color: #666;
        font-size: 11px;
        font-weight: 500;

        svg {
            width: 12px;
            height: 12px;
        }
    }

    :global(.toolbar-btn) {
        padding: 4px 8px !important;
        font-size: 11px !important;
        height: 24px !important;
        border-radius: 3px !important;
        
        svg {
            width: 12px !important;
            height: 12px !important;
        }
    }

    :global(.toolbar-btn.active) {
        background: var(--tf-primary-color) !important;
        color: #fff !important;
        border-color: var(--tf-primary-color) !important;
    }

    :global(.toolbar-btn-danger) {
        color: #dc3545 !important;
        
        &:hover {
            background: #dc3545 !important;
            color: #fff !important;
            border-color: #dc3545 !important;
        }
    }
</style>
