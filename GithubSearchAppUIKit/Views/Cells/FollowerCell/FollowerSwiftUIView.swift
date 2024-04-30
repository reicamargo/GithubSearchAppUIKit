//
//  FollowerView.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 30/04/24.
//

import SwiftUI

struct FollowerSwiftUIView: View {
    var follower: Follower
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: follower.avatarUrl)) { image in
                image
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                
            } placeholder: {
                Image(.avatarPlaceholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Text(follower.login)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            
        }
    }
}

#Preview {
    FollowerSwiftUIView(follower: Follower(login: "reicamargo", avatarUrl: "https://avatars.githubusercontent.com/u/1205229?v=4"))
}
