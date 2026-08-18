import SwiftUI
import AppKit

/// 轻量设计系统：间距、圆角、表面与边框令牌，统一主窗口视觉语言。
enum Design {
    // 8pt 间距栅格
    static let spacing1: CGFloat = 4
    static let spacing2: CGFloat = 8
    static let spacing3: CGFloat = 12
    static let spacing4: CGFloat = 16
    static let spacing5: CGFloat = 20
    static let spacing6: CGFloat = 24
    static let spacing8: CGFloat = 32

    // 圆角（Tahoe 液态玻璃：圆角更大、更柔和）
    static let radiusSm: CGFloat = 10
    static let radiusMd: CGFloat = 14
    static let radiusLg: CGFloat = 20

    // 表面与描边（自动适配浅/深色）
    static var cardBackground: some ShapeStyle { Color(nsColor: .textBackgroundColor) }
    static var cardBorder: some ShapeStyle { Color(nsColor: .separatorColor).opacity(0.6) }
    static var rowBackground: some ShapeStyle { Color(nsColor: .controlBackgroundColor) }
    static var fieldBackground: some ShapeStyle { Color(nsColor: .controlBackgroundColor) }

    /// 强调色：深灰（替换系统蓝，页面整体更沉稳、不刺眼）。
    /// Toggle 开态、Picker 选中、按钮、Header 方块、sheet 内 globe 均跟随此色。
    static var accent: Color { Color(white: 0.30) }
}

/// 分区卡片容器：统一内边距、表面、描边与轻微投影。
struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(Design.spacing5)
            .background(
                RoundedRectangle(cornerRadius: Design.radiusMd, style: .continuous)
                    .fill(Design.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Design.radiusMd, style: .continuous)
                            .stroke(Design.cardBorder, lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

/// 液态玻璃卡片（macOS 26 Tahoe Liquid Glass 风格）：
/// 26+ 使用系统原生 .glassEffect()（真正的液态玻璃：半透明折射、悬停边缘发光），
/// 旧系统回退到 thinMaterial + 手动高光。
struct GlassCard<Content: View>: View {
    let content: Content
    @State private var hovering = false

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(Design.spacing5)
            .modifier(LiquidGlass(cornerRadius: Design.radiusMd, hovering: hovering))
            .animation(.easeOut(duration: 0.18), value: hovering)
            .onHover { hovering = $0 }
    }
}

/// 液态玻璃修饰器：macOS 26 用系统 glassEffect；旧系统回退材质 + 手动高光。
struct LiquidGlass: ViewModifier {
    let cornerRadius: CGFloat
    let hovering: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            // 系统原生液态玻璃：自带材质、折射、圆角与悬停高光
            // 注意：.glassEffect() 默认形状是 capsule（椭圆），会让大卡片渲染成药丸形；
            // 显式指定 .rect(cornerRadius:) 使其贴合圆角矩形卡片，避免"透明椭圆"异象。
            content
                .glassEffect(in: .rect(cornerRadius: cornerRadius))
                .overlay(
                    // 增强悬停边缘高光（系统玻璃的发光叠加自定义亮边）
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(.white.opacity(hovering ? 0.35 : 0.10), lineWidth: 1)
                        .padding(1)
                )
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.thinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(.white.opacity(hovering ? 0.30 : 0.10), lineWidth: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(hovering ? 0.50 : 0.22), .clear],
                                        startPoint: .top, endPoint: .center
                                    ),
                                    lineWidth: 1
                                )
                                .padding(1)
                        )
                )
                .shadow(
                    color: Color.black.opacity(hovering ? 0.16 : 0.10),
                    radius: hovering ? 18 : 10,
                    x: 0, y: hovering ? 8 : 4
                )
        }
    }
}

/// 玻璃行：规则行等小单元的液态玻璃背景（ultraThin 材质 + 悬停高光）。
struct GlassRow<Content: View>: View {
    let content: Content
    @State private var hovering = false

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .modifier(LiquidGlass(cornerRadius: 10, hovering: hovering))
            .animation(.easeOut(duration: 0.15), value: hovering)
            .onHover { hovering = $0 }
    }
}

/// 解析应用图标：按 Bundle ID 取真实图标，失败回退到系统 app 符号。
func appIcon(for bundleID: String) -> Image {
    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
        return Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
    }
    return Image(systemName: "app.fill")
}
